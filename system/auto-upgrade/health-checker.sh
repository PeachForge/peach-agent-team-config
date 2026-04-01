#!/bin/bash
#
# health-checker.sh - 健康检查
# 负责升级后的系统健康验证
#

set -e

# 配置
WORKSPACE_DIR="$HOME/OneDrive/Peach-Workspace"
LOG_DIR="$WORKSPACE_DIR/system/logs"
LOG_FILE="$LOG_DIR/upgrade.log"
HEALTH_STATUS_FILE="$LOG_DIR/health_status.json"

# 健康检查项目
HEALTH_CHECKS=(
    "file_integrity"      # 文件完整性
    "config_valid"        # 配置有效性
    "skills_loaded"       # 技能包加载
    "git_status"          # Git 状态
    "permissions"         # 权限检查
    "disk_space"          # 磁盘空间
)

# 日志函数
health_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [HEALTH] [$level] $message" | tee -a "$LOG_FILE"
}

# 运行所有健康检查
run_health_check() {
    health_log "INFO" "=========================================="
    health_log "INFO" "开始健康检查"
    health_log "INFO" "=========================================="
    
    local total_checks=${#HEALTH_CHECKS[@]}
    local passed_checks=0
    local failed_checks=0
    local results=()
    
    for check in "${HEALTH_CHECKS[@]}"; do
        health_log "INFO" "检查：$check"
        
        if run_single_check "$check"; then
            health_log "SUCCESS" "✓ $check 通过"
            ((passed_checks++))
            results+=("\"$check\": \"passed\"")
        else
            health_log "ERROR" "✗ $check 失败"
            ((failed_checks++))
            results+=("\"$check\": \"failed\"")
        fi
    done
    
    # 生成健康报告
    generate_health_report "$passed_checks" "$total_checks" "${results[@]}"
    
    health_log "INFO" "=========================================="
    health_log "INFO" "健康检查完成"
    health_log "INFO" "总计：$total_checks, 通过：$passed_checks, 失败：$failed_checks"
    health_log "INFO" "=========================================="
    
    if [ $failed_checks -eq 0 ]; then
        health_log "SUCCESS" "所有检查通过"
        return 0
    else
        health_log "WARN" "$failed_checks 个检查失败"
        return 1
    fi
}

# 运行单个检查
run_single_check() {
    local check_name="$1"
    
    case "$check_name" in
        file_integrity)
            check_file_integrity
            ;;
        config_valid)
            check_config_valid
            ;;
        skills_loaded)
            check_skills_loaded
            ;;
        git_status)
            check_git_status
            ;;
        permissions)
            check_permissions
            ;;
        disk_space)
            check_disk_space
            ;;
        *)
            health_log "WARN" "未知检查：$check_name"
            return 1
            ;;
    esac
}

# 检查文件完整性
check_file_integrity() {
    local critical_files=(
        "AGENTS.md"
        "SOUL.md"
        "USER.md"
        "system/auto-upgrade/upgrade-manager.sh"
    )
    
    for file in "${critical_files[@]}"; do
        if [ ! -f "$WORKSPACE_DIR/$file" ]; then
            health_log "ERROR" "缺少关键文件：$file"
            return 1
        fi
    done
    
    # 检查脚本可执行性
    local scripts=(
        "system/auto-upgrade/upgrade-manager.sh"
        "system/auto-upgrade/version-checker.sh"
        "system/auto-upgrade/backup-manager.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ ! -x "$WORKSPACE_DIR/$script" ]; then
            health_log "WARN" "脚本不可执行：$script"
        fi
    done
    
    return 0
}

# 检查配置有效性
check_config_valid() {
    # 检查 AGENTS.md
    if [ -f "$WORKSPACE_DIR/AGENTS.md" ]; then
        if ! grep -q "AGENTS.md" "$WORKSPACE_DIR/AGENTS.md" 2>/dev/null; then
            health_log "WARN" "AGENTS.md 内容可能不完整"
        fi
    fi
    
    # 检查 SOUL.md
    if [ -f "$WORKSPACE_DIR/SOUL.md" ]; then
        if ! grep -q "SOUL" "$WORKSPACE_DIR/SOUL.md" 2>/dev/null; then
            health_log "WARN" "SOUL.md 内容可能不完整"
        fi
    fi
    
    # 检查 .openclawrc（如果存在）
    if [ -f "$WORKSPACE_DIR/.openclawrc" ]; then
        # 验证 JSON 格式
        if command -v python3 &> /dev/null; then
            if ! python3 -c "import json; json.load(open('$WORKSPACE_DIR/.openclawrc'))" 2>/dev/null; then
                health_log "WARN" ".openclawrc JSON 格式可能无效"
            fi
        fi
    fi
    
    return 0
}

# 检查技能包加载
check_skills_loaded() {
    local skills_dir="$WORKSPACE_DIR/skills"
    
    if [ ! -d "$skills_dir" ]; then
        health_log "WARN" "技能目录不存在"
        return 0  # 不视为失败，可能是正常情况
    fi
    
    # 检查是否有技能文件
    local skill_count=$(find "$skills_dir" -name "SKILL.md" 2>/dev/null | wc -l)
    
    if [ "$skill_count" -eq 0 ]; then
        health_log "WARN" "未发现技能文件"
    else
        health_log "INFO" "发现 $skill_count 个技能"
    fi
    
    return 0
}

# 检查 Git 状态
check_git_status() {
    if ! command -v git &> /dev/null; then
        health_log "INFO" "Git 未安装，跳过 Git 检查"
        return 0
    fi
    
    if [ ! -d "$WORKSPACE_DIR/.git" ]; then
        health_log "INFO" "非 Git 仓库，跳过 Git 检查"
        return 0
    fi
    
    # 检查是否有未提交的更改
    cd "$WORKSPACE_DIR"
    local changes=$(git status --porcelain 2>/dev/null | wc -l)
    
    if [ "$changes" -gt 0 ]; then
        health_log "WARN" "有 $changes 个未提交的更改"
    else
        health_log "INFO" "Git 工作区干净"
    fi
    
    return 0
}

# 检查权限
check_permissions() {
    # 检查工作目录可写
    if [ ! -w "$WORKSPACE_DIR" ]; then
        health_log "ERROR" "工作目录不可写"
        return 1
    fi
    
    # 检查日志目录可写
    if [ ! -w "$LOG_DIR" ]; then
        health_log "ERROR" "日志目录不可写"
        return 1
    fi
    
    # 检查备份目录可写
    local backup_dir="$WORKSPACE_DIR/system/backups"
    if [ ! -w "$backup_dir" ] 2>/dev/null; then
        mkdir -p "$backup_dir"
        if [ ! -w "$backup_dir" ]; then
            health_log "ERROR" "备份目录不可写"
            return 1
        fi
    fi
    
    return 0
}

# 检查磁盘空间
check_disk_space() {
    local min_space_mb=100  # 最少需要 100MB
    
    local available_kb=$(df -k "$WORKSPACE_DIR" | tail -1 | awk '{print $4}')
    local available_mb=$((available_kb / 1024))
    
    if [ "$available_mb" -lt "$min_space_mb" ]; then
        health_log "ERROR" "磁盘空间不足：${available_mb}MB < ${min_space_mb}MB"
        return 1
    fi
    
    health_log "INFO" "磁盘空间充足：${available_mb}MB"
    return 0
}

# 生成健康报告
generate_health_report() {
    local passed="$1"
    local total="$2"
    shift 2
    local results=("$@")
    
    local timestamp=$(date -Iseconds)
    
    # 生成 JSON 状态文件
    cat > "$HEALTH_STATUS_FILE" << EOF
{
  "timestamp": "$timestamp",
  "summary": {
    "total": $total,
    "passed": $passed,
    "failed": $((total - passed))
  },
  "checks": {
    $(IFS=,; echo "${results[*]}")
  },
  "status": "$([ $passed -eq $total ] && echo "healthy" || echo "unhealthy")"
}
EOF
    
    # 生成 Markdown 报告
    local report_file="$LOG_DIR/health_report_$(date '+%Y%m%d_%H%M%S').md"
    cat > "$report_file" << EOF
# 健康检查报告

## 检查时间
$timestamp

## 摘要
- 总检查项：$total
- 通过：$passed
- 失败：$((total - passed))
- 状态：$([ $passed -eq $total ] && echo "✓ 健康" || echo "✗ 异常")

## 详细结果

$(for result in "${results[@]}"; do
    check_name=$(echo "$result" | cut -d'"' -f2)
    check_status=$(echo "$result" | cut -d'"' -f4)
    if [ "$check_status" = "passed" ]; then
        echo "✓ $check_name"
    else
        echo "✗ $check_name"
    fi
done)

## 建议
$([ $passed -eq $total ] && echo "系统运行正常，无需操作。" || echo "部分检查失败，请查看日志了解详情。")

---
*此报告由 health-checker.sh 自动生成*
EOF
    
    health_log "INFO" "健康报告：$report_file"
}

# 获取健康状态
get_health_status() {
    if [ -f "$HEALTH_STATUS_FILE" ]; then
        cat "$HEALTH_STATUS_FILE"
    else
        echo "无健康检查记录"
    fi
}

# 如果直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-check}" in
        check)
            run_health_check
            ;;
        status)
            get_health_status
            ;;
        help|*)
            echo "用法：$0 <command>"
            echo ""
            echo "命令:"
            echo "  check     运行健康检查"
            echo "  status    显示健康状态"
            echo "  help      显示帮助"
            ;;
    esac
fi
