# 🖥️ 系统监控系统

> Peach 系统监控解决方案 - 守护你的 Agent 团队

---

## 📁 目录结构

```
monitoring/
├── monitoring-config.json    # 监控配置
├── alert-rules.json          # 告警规则
├── dashboard-template.md     # 监控仪表板模板
├── daily-status-report.md    # 每日状态报告模板
├── monitor.sh                # 监控脚本
├── README.md                 # 本文档
└── logs/
    └── monitoring.log        # 监控日志
```

---

## 🚀 快速开始

### 1. 配置 Telegram 通知

编辑 `monitoring-config.json`，填入你的 Telegram Bot Token：

```json
"telegram": {
  "enabled": true,
  "recipient": "peter",
  "chat_id": "6869363927",
  "bot_token": "YOUR_BOT_TOKEN"
}
```

### 2. 运行监控

```bash
# 赋予执行权限
chmod +x monitor.sh

# 运行一次监控
./monitor.sh

# 查看日志
tail -f logs/monitoring.log
```

### 3. 设置定时任务（可选）

```bash
# 编辑 crontab
crontab -e

# 添加每 5 分钟检查一次
*/5 * * * * /Users/peter_us/OneDrive/Peach-Workspace/monitoring/monitor.sh

# 每天 9 点生成报告
0 9 * * * /Users/peter_us/OneDrive/Peach-Workspace/monitoring/monitor.sh --report
```

---

## 📊 监控指标

### 进程监控
- Guardian 守护进程存活状态
- 6 个内容 Agent 健康状态
- 自升级系统状态
- 配置管理系统状态

### 服务监控
- Telegram 渠道 API 健康
- 微博/小红书发布成功率
- 数据追踪系统数据流

### 资源监控
- CPU 使用率（警告 70% / 严重 90%）
- 内存使用率（警告 75% / 严重 95%）
- 磁盘空间（警告 80% / 严重 95%）

---

## 🔔 告警级别

| 级别 | 图标 | 说明 | 响应 |
|------|------|------|------|
| P0 | 🔴 | 严重 - Guardian 宕机 | 立即处理 |
| P1 | 🟠 | 重要 - Agent 失败 | 尽快处理 |
| P2 | 🟡 | 警告 - 发布失败/资源高 | 关注处理 |
| P3 | 🟢 | 信息 - 日常报告 | 定期查看 |

---

## 📝 告警模板

系统预置了以下告警模板（在 `alert-rules.json` 中配置）：

- `guardian_critical` - Guardian 宕机告警
- `agent_failed` - Agent 执行失败告警
- `upgrade_failed` - 自升级失败告警
- `publish_warning` - 发布成功率低告警
- `resource_warning` - 资源使用率高告警
- `disk_warning` - 磁盘空间不足告警
- `daily_report` - 每日状态报告

---

## 📈 监控仪表板

监控仪表板模板位于 `dashboard-template.md`，支持：

- 实时系统状态概览
- 活跃告警列表
- Agent 团队状态
- 资源使用图表
- 发布系统统计
- 数据追踪状态

---

## 📋 每日报告

每日状态报告包含：

- 执行摘要
- 关键指标
- Agent 团队表现
- 发布系统统计
- 告警汇总
- 资源使用情况
- 趋势分析
- 问题与建议

报告自动生成到 `daily-status-YYYYMMDD.md`

---

## 🔧 自定义配置

### 修改监控间隔

编辑 `monitoring-config.json`：

```json
"interval": {
  "quick": 60,      // 快速检查（秒）
  "standard": 300,  // 标准检查（秒）
  "daily": 86400    // 每日报告（秒）
}
```

### 添加新的监控目标

在 `monitoring-config.json` 的 `targets` 中添加：

```json
"new_service": {
  "name": "新服务名称",
  "type": "service",
  "check": "health_endpoint",
  "priority": "P2",
  "enabled": true
}
```

### 添加新的告警规则

在 `alert-rules.json` 的 `rules` 数组中添加新规则。

---

## 🐛 故障排查

### 查看日志

```bash
# 查看最新日志
tail -100 logs/monitoring.log

# 搜索错误
grep ERROR logs/monitoring.log

# 实时查看
tail -f logs/monitoring.log
```

### 常见问题

1. **Telegram 通知不发送**
   - 检查 Bot Token 是否正确
   - 检查 Chat ID 是否正确
   - 检查网络连接

2. **监控脚本无法执行**
   - 确保有执行权限：`chmod +x monitor.sh`
   - 检查 bash 路径：`which bash`

3. **资源监控数据不准确**
   - macOS 和 Linux 命令不同，需要根据系统调整

---

## 📞 支持

如有问题，请联系系统管理员或查看文档。

---

*最后更新：2026-04-02*
