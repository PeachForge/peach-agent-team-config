#!/bin/bash
#
# upgrade-manager.sh - 升级管理器
# 负责协调整个升级流程
#

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(dirname "$SCRIPT_DIR")"
WORKSPACE_DIR="$HOME/OneDrive/Peach-Workspace"
LOG_DIR="$WORKSPACE_DIR/system/logs"
VERSIONS_DIR="$WORKSPACE_DIR/system/versions"
BACKUP_DIR="$WORKSPACE_DIR/system/backups"
LOG_FILE="$LOG_DIR/upgrade.log"
VERSION_HISTORY="$VERSIONS_DIR/version-history.md"

# 导入其他脚本
source "$SCRIPT_DIR/version-checker.sh"
source "$SCRIPT_DIR/backup-manager.sh"
source "$SCRIPT_DIR/config-migrator.sh"
source "$SCRIPT_DIR/health-checker.sh"
source "$SCRIPT_DIR/rollback-manager.sh"

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }
log_success() { log "SUCCESS" "$1"; }

# 清理旧备份（保留最近 3 个）
cleanup_old_backups() {
    log_info "清理旧备份..."
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(ls -1t "$BACKUP_DIR" 2>/dev/null | wc -l)
        if [ "$backup_count" -gt 3 ]; then
            local to_delete=$((backup_count - 3))
            ls -1t "$BACKUP_DIR" | tail -n "$to_delete" | while read backup; do
                rm -rf "$BACKUP_DIR/$backup"
                log_info "删除旧备份：$backup"
            done
        fi
    fi
}

# 主升级流程
do_upgrade() {
    local force_upgrade="${1:-false}"
    
    log_info "=========================================="
    log_info "开始升级流程"
    log_info "=========================================="
    
    # 步骤 1: 检查新版本
    log_info "步骤 1: 检查新版本..."
    local current_version=$(get_current_version)
    local latest_version=$(get_latest_version)
    
    log_info "当前版本：$current_version"
    log_info "最新版本：$latest_version"
    
    if [ "$current_version" = "$latest_version" ] && [ "$force_upgrade" = "false" ]; then
        log_success "已是最新版本，无需升级"
        return 0
    fi
    
    if [ "$force_upgrade" = "false" ]; then
        log_info "发现新版本，开始升级..."
    else
        log_info "强制升级模式"
    fi
    
    # 步骤 2: 备份当前版本
    log_info "步骤 2: 备份当前版本..."
    local backup_id=$(create_backup "$current_version")
    if [ $? -ne 0 ]; then
        log_error "备份失败，中止升级"
        return 1
    fi
    log_success "备份创建成功：$backup_id"
    
    # 步骤 3: 下载新版本
    log_info "步骤 3: 下载新版本..."
    if ! download_new_version "$latest_version"; then
        log_error "下载新版本失败"
        log_info "触发回滚..."
        do_rollback "$backup_id"
        return 1
    fi
    log_success "新版本下载成功"
    
    # 步骤 4: 迁移配置
    log_info "步骤 4: 迁移配置..."
    if ! migrate_config "$current_version" "$latest_version"; then
        log_error "配置迁移失败"
        log_info "触发回滚..."
        do_rollback "$backup_id"
        return 1
    fi
    log_success "配置迁移成功"
    
    # 步骤 5: 验证升级
    log_info "步骤 5: 验证升级..."
    if ! run_health_check; then
        log_error "健康检查失败"
        log_info "触发回滚..."
        do_rollback "$backup_id"
        return 1
    fi
    log_success "健康检查通过"
    
    # 步骤 6: 更新版本记录
    log_info "步骤 6: 更新版本记录..."
    update_version_history "$current_version" "$latest_version"
    
    # 步骤 7: 清理旧备份
    log_info "步骤 7: 清理旧备份..."
    cleanup_old_backups
    
    log_info "=========================================="
    log_success "升级完成！从 $current_version 升级到 $latest_version"
    log_info "=========================================="
    
    return 0
}

# 执行回滚
do_rollback() {
    local backup_id="${1:-latest}"
    
    log_info "=========================================="
    log_info "开始回滚流程"
    log_info "=========================================="
    
    if [ "$backup_id" = "latest" ]; then
        backup_id=$(get_latest_backup)
    fi
    
    if [ -z "$backup_id" ]; then
        log_error "未找到可用的备份"
        return 1
    fi
    
    if restore_backup "$backup_id"; then
        log_success "回滚成功"
        return 0
    else
        log_error "回滚失败"
        return 1
    fi
}

# 显示状态
show_status() {
    echo "=========================================="
    echo "系统升级状态"
    echo "=========================================="
    echo "当前版本：$(get_current_version)"
    echo "最新版本：$(get_latest_version)"
    echo ""
    echo "备份数量：$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l | tr -d ' ')"
    echo "最新备份：$(get_latest_backup)"
    echo ""
    echo "最近升级日志:"
    tail -n 10 "$LOG_FILE" 2>/dev/null || echo "无日志记录"
    echo "=========================================="
}

# 主入口
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        upgrade)
            do_upgrade "$@"
            ;;
        rollback)
            do_rollback "$@"
            ;;
        status)
            show_status
            ;;
        check)
            local current=$(get_current_version)
            local latest=$(get_latest_version)
            if [ "$current" = "$latest" ]; then
                echo "已是最新版本 ($current)"
            else
                echo "有新版本可用：$current -> $latest"
            fi
            ;;
        help|*)
            echo "用法：$0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  upgrade     执行升级 (可加 --force 强制升级)"
            echo "  rollback    回滚到上一个版本"
            echo "  status      显示升级状态"
            echo "  check       检查是否有新版本"
            echo "  help        显示帮助信息"
            ;;
    esac
}

# 如果直接执行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
