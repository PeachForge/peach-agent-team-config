# 🖥️ 系统监控仪表板

> 最后更新：{{timestamp}} | 刷新间隔：5 分钟

---

## 📊 系统概览

| 指标 | 状态 | 数值 | 趋势 |
|------|------|------|------|
| Guardian 守护进程 | {{guardian_status}} | {{guardian_uptime}} | {{guardian_trend}} |
| 内容 Agent 团队 | {{agents_status}} | {{agents_active}}/{{agents_total}} | {{agents_trend}} |
| 发布系统 | {{publish_status}} | 成功率 {{publish_rate}}% | {{publish_trend}} |
| 数据追踪 | {{tracking_status}} | {{tracking_events}} 事件/小时 | {{tracking_trend}} |

---

## 🔴 告警状态

### 当前活跃告警

{{#if active_alerts}}
| 级别 | 告警名称 | 触发时间 | 状态 |
|------|----------|----------|------|
{{#each active_alerts}}
| {{emoji}} {{priority}} | {{name}} | {{triggered_at}} | {{status}} |
{{/each}}
{{else}}
✅ 无活跃告警
{{/if}}

### 24 小时告警统计

| 级别 | 数量 | 已解决 | 平均恢复时间 |
|------|------|--------|--------------|
| P0 🔴 | {{p0_count}} | {{p0_resolved}} | {{p0_mttr}} |
| P1 🟠 | {{p1_count}} | {{p1_resolved}} | {{p1_mttr}} |
| P2 🟡 | {{p2_count}} | {{p2_resolved}} | {{p2_mttr}} |
| P3 🟢 | {{p3_count}} | {{p3_resolved}} | {{p3_mttr}} |

---

## 🤖 Agent 团队状态

| Agent 名称 | 状态 | 最后执行 | 成功率 | 错误数 |
|------------|------|----------|--------|--------|
| 微博发布 Agent | {{weibo_status}} | {{weibo_last_run}} | {{weibo_success_rate}}% | {{weibo_errors}} |
| 小红书发布 Agent | {{xiaohongshu_status}} | {{xiaohongshu_last_run}} | {{xiaohongshu_success_rate}}% | {{xiaohongshu_errors}} |
| 内容生成 Agent | {{content_status}} | {{content_last_run}} | {{content_success_rate}}% | {{content_errors}} |
| 数据分析 Agent | {{analytics_status}} | {{analytics_last_run}} | {{analytics_success_rate}}% | {{analytics_errors}} |
| 用户交互 Agent | {{interaction_status}} | {{interaction_last_run}} | {{interaction_success_rate}}% | {{interaction_errors}} |
| 自动升级 Agent | {{upgrade_status}} | {{upgrade_last_run}} | {{upgrade_success_rate}}% | {{upgrade_errors}} |

---

## 📈 资源监控

### CPU 使用率

```
{{cpu_chart}}
```

当前：{{cpu_current}}% | 平均：{{cpu_avg}}% | 峰值：{{cpu_peak}}%

### 内存使用率

```
{{memory_chart}}
```

当前：{{memory_current}}% | 平均：{{memory_avg}}% | 峰值：{{memory_peak}}%

### 磁盘使用率

| 分区 | 已用 | 总计 | 使用率 | 状态 |
|------|------|------|--------|------|
| / | {{root_used}} | {{root_total}} | {{root_percent}}% | {{root_status}} |
| /Users | {{users_used}} | {{users_total}} | {{users_percent}}% | {{users_status}} |

---

## 📤 发布系统状态

### 发布统计（24 小时）

| 平台 | 成功 | 失败 | 成功率 | 最后发布 |
|------|------|------|--------|----------|
| 微博 | {{weibo_success}} | {{weibo_failed}} | {{weibo_rate}}% | {{weibo_last}} |
| 小红书 | {{xhs_success}} | {{xhs_failed}} | {{xhs_rate}}% | {{xhs_last}} |

### 发布趋势

```
{{publish_trend_chart}}
```

---

## 📊 数据追踪

### 数据流状态

| 数据源 | 状态 | 事件数 | 延迟 |
|--------|------|--------|------|
| Telegram | {{tg_data_status}} | {{tg_events}} | {{tg_latency}}ms |
| 微博 API | {{weibo_data_status}} | {{weibo_events}} | {{weibo_latency}}ms |
| 小红书 API | {{xhs_data_status}} | {{xhs_events}} | {{xhs_latency}}ms |

### API 调用统计

| API | 调用次数 | 成功 | 失败 | 成功率 |
|-----|----------|------|------|--------|
| Telegram Bot API | {{tg_calls}} | {{tg_success}} | {{tg_fail}} | {{tg_rate}}% |
| 微博 API | {{weibo_api_calls}} | {{weibo_api_success}} | {{weibo_api_fail}} | {{weibo_api_rate}}% |
| 小红书 API | {{xhs_api_calls}} | {{xhs_api_success}} | {{xhs_api_fail}} | {{xhs_api_rate}}% |

---

## 📝 最近日志

| 时间 | 级别 | 消息 |
|------|------|------|
{{#each recent_logs}}
| {{timestamp}} | {{level}} | {{message}} |
{{/each}}

---

## 🔧 系统信息

- **监控版本**: {{monitor_version}}
- **运行时间**: {{uptime}}
- **最后检查**: {{last_check}}
- **下次检查**: {{next_check}}

---

*自动生成 | 刷新页面获取最新数据*
