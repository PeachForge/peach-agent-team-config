#!/bin/bash
#
# rollback-manager.sh - 回滚管理
# 负责系统回滚操作
#

set -e

# 配置
WORKSPACE_DIR="$HOME/OneDrive/Peach-Workspace"
BACKUP_DIR="$WORKSPACE_DIR/system/backups"
LOG_DIR="$WORKSPACE_DIR/system/logs"
LOG_FILE="$LOG_DIR/upgrade.log"
VERSION_FILE="$WORKSPACE_DIR/.version"

# 日志函数
rollback_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [ROLLBACK] [$level] $message" | tee -a "$LOG_FILE"
}

# 执行回滚
do_rollback() {
    local backup_id="${1:-latest}"
    local reason="${2:-user_requested}"
    
    rollback_log "INFO" "=========================================="
    rollback_log "INFO" "开始回滚流程"
    rollback_log "INFO" "=========================================="
    rollback_log "INFO" "回滚目标：$backup_id"
    rollback_log "INFO" "回滚原因：$reason"
    
    # 获取备份 ID
    if [ "$backup_id" = "latest" ]; then
        backup_id=$(ls -1t "$BACKUP_DIR" 2>/dev/null | head -n 1)
        if [ -z "$backup_id" ]; then
            rollback_log "ERROR" "未找到可用的备份"
            echo "错误：未找到可用的备份"
            return 1
        fi
        rollback_log "INFO" "使用最新备份：$backup_id"
    fi
    
    local backup_path="$BACKUP_DIR/$backup_id"
    
    # 验证备份存在
    if [ ! -d "$backup_path" ]; then
        rollback_log "ERROR" "备份不存在：$backup_id"
        echo "错误：备份不存在：$backup_id"
        return 1
    fi
    
    # 读取备份版本
    local backup_version="unknown"
    local manifest="$backup_path/manifest.json"
    if [ -f "$manifest" ]; then
        backup_version=$(grep '"version"' "$manifest" | cut -d'"' -f4)
    fi
    
    rollback_log "INFO" "备份版本：$backup_version"
    
    # 创建回滚前快照
    rollback_log "INFO" "创建回滚前快照..."
    local pre_rollback_backup="pre_rollback_$(date '+%Y%m%d_%H%M%S')"
    mkdir -p "$BACKUP_DIR/$pre_rollback_backup"
    
    # 备份当前关键文件
    for item in "system/auto-upgrade" ".version"; do
        local source="$WORKSPACE_DIR/$item"
        if [ -e "$source" ]; then
            local dest="$BACKUP_DIR/$pre_rollback_backup/$item"
            mkdir -p "$(dirname "$dest")"
            if [ -d "$source" ]; then
                cp -r "$source" "$dest"
            else
                cp "$source" "$dest"
            fi
        fi
    done
    
    rollback_log "INFO" "回滚前快照：$pre_rollback_backup"
    
    # 恢复备份
    rollback_log "INFO" "开始恢复备份..."
    
    # 读取并恢复备份项
    if [ -f "$manifest" ]; then
        grep -o '"[^"]*"' "$manifest" | grep -v 'backup_id\|version\|timestamp\|items' | \
            tr -d '"' | while read item; do
                local source_path="$backup_path/$item"
                local dest_path="$WORKSPACE_DIR/$item"
                
                if [ -e "$source_path" ]; then
                    local dest_dir=$(dirname "$dest_path")
                    mkdir -p "$dest_dir"
                    
                    if [ -d "$source_path" ]; then
                        rm -rf "$dest_path"
                        cp -r "$source_path" "$dest_path"
                    else
                        cp "$source_path" "$dest_path"
                    fi
                    
                    rollback_log "INFO" "恢复：$item"
                fi
            done
    fi
    
    # 恢复版本号
    if [ "$backup_version" != "unknown" ]; then
        echo "$backup_version" > "$VERSION_FILE"
        rollback_log "INFO" "恢复版本号：$backup_version"
    fi
    
    # 记录回滚
    local rollback_record="$BACKUP_DIR/$backup_id/rollback.json"
    cat > "$rollback_record" << EOF
{
  "rollback_time": "$(date -Iseconds)",
  "from_backup": "$backup_id",
  "reason": "$reason",
  "pre_rollback_backup": "$pre_rollback_backup"
}
EOF
    
    rollback_log "SUCCESS" "=========================================="
    rollback_log "SUCCESS" "回滚完成！"
    rollback_log "SUCCESS" "已回滚到版本：$backup_version"
    rollback_log "SUCCESS" "=========================================="
    
    echo ""
    echo "回滚成功！"
    echo "已回滚到版本：$backup_version"
    echo "回滚前快照：$pre_rollback_backup"
    
    return 0
}

# 自动回滚（用于升级失败时调用）
auto_rollback() {
    local backup_id="$1"
    local failure_reason="${2:-unknown_failure}"
    
    rollback_log "WARN" "=========================================="
    rollback_log "WARN" "触发自动回滚"
    rollback_log "WARN" "=========================================="
    rollback_log "ERROR" "失败原因：$failure_reason"
    
    if [ -z "$backup_id" ]; then
        backup_id="latest"
    fi
    
    if do_rollback "$backup_id" "auto_rollback: $failure_reason"; then
        rollback_log "SUCCESS" "自动回滚成功"
        
        # 发送告警（可以通过消息工具）
        send_rollback_alert "$backup_id" "$failure_reason"
        
        return 0
    else
        rollback_log "ERROR" "自动回滚失败！需要人工干预"
        send_critical_alert "auto_rollback_failed" "$failure_reason"
        return 1
    fi
}

# 发送回滚告警
send_rollback_alert() {
    local backup_id="$1"
    local reason="$2"
    
    # 这里可以集成消息通知
    # 例如：发送 Telegram 消息、邮件等
    rollback_log "INFO" "告警：系统已回滚到 $backup_id，原因：$reason"
    
    # 示例：写入告警文件
    local alert_file="$LOG_DIR/rollback_alerts.log"
    echo "[$(date -Iseconds)] ROLLBACK_ALERT: backup=$backup_id, reason=$reason" >> "$alert_file"
}

# 发送严重告警
send_critical_alert() {
    local alert_type="$1"
    local details="$2"
    
    rollback_log "ERROR" "严重告警：$alert_type - $details"
    
    local alert_file="$LOG_DIR/critical_alerts.log"
    echo "[$(date -Iseconds)] CRITICAL_ALERT: type=$alert_type, details=$details" >> "$alert_file"
}

# 列出回滚历史
list_rollback_history() {
    echo "回滚历史:"
    echo "=========================================="
    
    if [ -d "$BACKUP_DIR" ]; then
        find "$BACKUP_DIR" -name "rollback.json" 2>/dev/null | while read record; do
            local backup_dir=$(dirname "$record")
            local backup_id=$(basename "$backup_dir")
            
            echo ""
            echo "备份：$backup_id"
            if [ -f "$record" ]; then
                cat "$record"
            fi
        done
    fi
    
    echo ""
    echo "=========================================="
}

# 如果直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        rollback)
            do_rollback "${2:-latest}" "${3:-user_requested}"
            ;;
        auto)
            auto_rollback "$2" "$3"
            ;;
        history)
            list_rollback_history
            ;;
        help|*)
            echo "用法：$0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  rollback [backup_id] [reason]  执行回滚"
            echo "  auto <backup_id> <reason>      自动回滚（用于升级失败）"
            echo "  history                        查看回滚历史"
            echo "  help                           显示帮助"
            ;;
    esac
fi
