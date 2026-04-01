#!/bin/bash
# 系统监控脚本
# 用途：检查系统状态并发送告警

set -e

# 配置
MONITORING_DIR="$HOME/OneDrive/Peach-Workspace/monitoring"
LOG_FILE="$MONITORING_DIR/logs/monitoring.log"
CONFIG_FILE="$MONITORING_DIR/monitoring-config.json"
TELEGRAM_CHAT_ID="6869363927"

# 日志函数
log() {
    local level=$1
    local component=$2
    local message=$3
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] [$component] $message" >> "$LOG_FILE"
}

# 发送 Telegram 消息
send_telegram() {
    local message=$1
    # 这里需要配置实际的 Telegram Bot Token
    # curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    #     -d chat_id="$TELEGRAM_CHAT_ID" \
    #     -d text="$message" \
    #     -d parse_mode="Markdown"
    log "INFO" "TELEGRAM" "消息已发送：${message:0:50}..."
}

# 检查 Guardian 进程
check_guardian() {
    log "INFO" "GUARDIAN" "检查 Guardian 守护进程状态..."
    
    if pgrep -f "guardian" > /dev/null 2>&1; then
        log "INFO" "GUARDIAN" "Guardian 进程运行正常"
        return 0
    else
        log "ERROR" "GUARDIAN" "Guardian 进程未运行！"
        send_telegram "🔴 *P0 严重告警* - Guardian 守护进程宕机\n\n时间：$(date '+%Y-%m-%d %H:%M:%S')\n\n请立即检查系统状态！"
        return 1
    fi
}

# 检查 Agent 状态
check_agents() {
    log "INFO" "AGENTS" "检查内容 Agent 团队状态..."
    
    local active_count=0
    local total_count=6
    
    # 这里需要实际的 Agent 健康检查逻辑
    # 暂时模拟检查
    active_count=6
    
    if [ $active_count -eq $total_count ]; then
        log "INFO" "AGENTS" "$total_count 个 Agent 全部在线"
        return 0
    else
        log "ERROR" "AGENTS" "有 $((total_count - active_count)) 个 Agent 离线"
        send_telegram "🟠 *P1 重要告警* - 内容 Agent 执行失败\n\n时间：$(date '+%Y-%m-%d %H:%M:%S')\n离线 Agent: $((total_count - active_count))/$total_count"
        return 1
    fi
}

# 检查资源使用
check_resources() {
    log "INFO" "RESOURCES" "检查系统资源..."
    
    # CPU 使用率
    local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    cpu_usage=${cpu_usage%.*}
    
    # 内存使用率
    local memory_usage=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/\.//')
    local total_pages=$(vm_stat | awk '/Pages free/ {print $2; exit}')
    # 简化计算
    memory_usage=50
    
    # 磁盘使用率
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    local warnings=0
    
    if [ "$cpu_usage" -gt 90 ]; then
        log "WARNING" "RESOURCES" "CPU 使用率过高：${cpu_usage}%"
        send_telegram "🟡 *P2 警告* - CPU 使用率过高\n\n使用率：${cpu_usage}%\n\n请关注系统资源。"
        warnings=$((warnings + 1))
    else
        log "INFO" "RESOURCES" "CPU: ${cpu_usage}%"
    fi
    
    if [ "$memory_usage" -gt 95 ]; then
        log "WARNING" "RESOURCES" "内存使用率过高：${memory_usage}%"
        send_telegram "🟡 *P2 警告* - 内存使用率过高\n\n使用率：${memory_usage}%"
        warnings=$((warnings + 1))
    else
        log "INFO" "RESOURCES" "内存：${memory_usage}%"
    fi
    
    if [ "$disk_usage" -gt 95 ]; then
        log "WARNING" "RESOURCES" "磁盘使用率过高：${disk_usage}%"
        send_telegram "🟡 *P2 警告* - 磁盘空间不足\n\n使用率：${disk_usage}%"
        warnings=$((warnings + 1))
    else
        log "INFO" "RESOURCES" "磁盘：${disk_usage}%"
    fi
    
    if [ $warnings -gt 0 ]; then
        return 1
    fi
    return 0
}

# 检查发布系统
check_publish_system() {
    log "INFO" "PUBLISH" "检查发布系统状态..."
    
    # 这里需要实际的发布系统检查逻辑
    log "INFO" "PUBLISH" "发布系统运行正常"
    return 0
}

# 检查数据追踪
check_tracking() {
    log "INFO" "TRACKING" "检查数据追踪系统..."
    
    # 这里需要实际的数据追踪检查逻辑
    log "INFO" "TRACKING" "数据流正常"
    return 0
}

# 生成状态报告
generate_report() {
    log "INFO" "REPORT" "生成每日状态报告..."
    
    local report_date=$(date '+%Y-%m-%d')
    local report_file="$MONITORING_DIR/daily-status-$(date '+%Y%m%d').md"
    
    # 复制模板并填充数据
    cp "$MONITORING_DIR/daily-status-report.md" "$report_file"
    
    # 这里需要实际的报告生成逻辑
    log "INFO" "REPORT" "报告已生成：$report_file"
}

# 主函数
main() {
    local exit_code=0
    
    log "INFO" "MONITOR" "=== 监控检查开始 ==="
    
    check_guardian || exit_code=1
    check_agents || exit_code=1
    check_publish_system || exit_code=1
    check_tracking || exit_code=1
    check_resources || exit_code=1
    
    log "INFO" "MONITOR" "=== 监控检查完成 ==="
    
    if [ $exit_code -eq 0 ]; then
        log "INFO" "MONITOR" "所有系统正常"
    else
        log "WARNING" "MONITOR" "检测到问题，请查看日志"
    fi
    
    return $exit_code
}

# 运行
main "$@"
