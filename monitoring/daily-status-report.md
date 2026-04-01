# 📋 系统每日状态报告

**报告日期**: {{date}}  
**生成时间**: {{timestamp}}  
**报告周期**: {{period_start}} 至 {{period_end}}

---

## 📊 执行摘要

{{#if overall_status == 'healthy'}}
### ✅ 系统运行正常

所有核心组件运行正常，无严重告警。
{{else if overall_status == 'warning'}}
### ⚠️ 系统存在警告

存在 {{warning_count}} 个警告，需要关注。
{{else}}
### 🔴 系统存在严重问题

存在 {{critical_count}} 个严重问题，需要立即处理。
{{/if}}

---

## 🎯 关键指标

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| 系统可用性 | 99.9% | {{availability}}% | {{availability_status}} |
| 任务成功率 | 90% | {{task_success_rate}}% | {{task_status}} |
| 发布成功率 | 95% | {{publish_success_rate}}% | {{publish_status}} |
| API 成功率 | 98% | {{api_success_rate}}% | {{api_status}} |
| 平均响应时间 | <500ms | {{avg_response_time}}ms | {{response_status}} |

---

## 🤖 Agent 团队表现

### 执行统计

| Agent | 执行次数 | 成功 | 失败 | 成功率 | 平均耗时 |
|-------|----------|------|------|--------|----------|
| 微博发布 Agent | {{weibo_runs}} | {{weibo_success}} | {{weibo_fail}} | {{weibo_rate}}% | {{weibo_duration}}s |
| 小红书发布 Agent | {{xhs_runs}} | {{xhs_success}} | {{xhs_fail}} | {{xhs_rate}}% | {{xhs_duration}}s |
| 内容生成 Agent | {{content_runs}} | {{content_success}} | {{content_fail}} | {{content_rate}}% | {{content_duration}}s |
| 数据分析 Agent | {{analytics_runs}} | {{analytics_success}} | {{analytics_fail}} | {{analytics_rate}}% | {{analytics_duration}}s |
| 用户交互 Agent | {{interaction_runs}} | {{interaction_success}} | {{interaction_fail}} | {{interaction_rate}}% | {{interaction_duration}}s |
| 自动升级 Agent | {{upgrade_runs}} | {{upgrade_success}} | {{upgrade_fail}} | {{upgrade_rate}}% | {{upgrade_duration}}s |

### Agent 健康度

```
Agent 健康度评分：{{agent_health_score}}/100

{{agent_health_chart}}
```

---

## 📤 发布系统表现

### 发布统计

| 平台 | 计划发布 | 实际发布 | 成功 | 失败 | 跳过 | 成功率 |
|------|----------|----------|------|------|------|--------|
| 微博 | {{weibo_planned}} | {{weibo_actual}} | {{weibo_success}} | {{weibo_failed}} | {{weibo_skipped}} | {{weibo_rate}}% |
| 小红书 | {{xhs_planned}} | {{xhs_actual}} | {{xhs_success}} | {{xhs_failed}} | {{xhs_skipped}} | {{xhs_rate}}% |
| **总计** | {{total_planned}} | {{total_actual}} | {{total_success}} | {{total_failed}} | {{total_skipped}} | {{total_rate}}% |

### 发布失败分析

{{#if publish_failures.length > 0}}
| 时间 | 平台 | 错误类型 | 错误信息 |
|------|------|----------|----------|
{{#each publish_failures}}
| {{time}} | {{platform}} | {{error_type}} | {{error_message}} |
{{/each}}
{{else}}
✅ 今日无发布失败
{{/if}}

---

## 🔴 告警汇总

### 告警统计

| 级别 | 新增 | 已解决 | 进行中 | 平均恢复时间 |
|------|------|--------|--------|--------------|
| P0 🔴 | {{p0_new}} | {{p0_resolved}} | {{p0_active}} | {{p0_mttr}} |
| P1 🟠 | {{p1_new}} | {{p1_resolved}} | {{p1_active}} | {{p1_mttr}} |
| P2 🟡 | {{p2_new}} | {{p2_resolved}} | {{p2_active}} | {{p2_mttr}} |
| P3 🟢 | {{p3_new}} | {{p3_resolved}} | {{p3_active}} | {{p3_mttr}} |

### 今日告警详情

{{#if alerts.length > 0}}
| 时间 | 级别 | 告警名称 | 状态 | 恢复时间 |
|------|------|----------|------|----------|
{{#each alerts}}
| {{time}} | {{priority}} | {{name}} | {{status}} | {{recovery_time}} |
{{/each}}
{{else}}
✅ 今日无告警
{{/if}}

---

## 💻 资源使用

### CPU

- **平均使用率**: {{cpu_avg}}%
- **峰值使用率**: {{cpu_peak}}%
- **峰值时间**: {{cpu_peak_time}}

### 内存

- **平均使用率**: {{memory_avg}}%
- **峰值使用率**: {{memory_peak}}%
- **峰值时间**: {{memory_peak_time}}

### 磁盘

| 分区 | 起始使用率 | 结束使用率 | 变化 |
|------|------------|------------|------|
| / | {{root_start}}% | {{root_end}}% | {{root_change}}% |
| /Users | {{users_start}}% | {{users_end}}% | {{users_change}}% |

---

## 📊 数据追踪

### 数据流统计

| 数据源 | 事件总数 | 成功处理 | 失败 | 丢失 | 完整性 |
|--------|----------|----------|------|------|--------|
| Telegram | {{tg_events}} | {{tg_processed}} | {{tg_failed}} | {{tg_lost}} | {{tg_integrity}}% |
| 微博 | {{weibo_events}} | {{weibo_processed}} | {{weibo_failed}} | {{weibo_lost}} | {{weibo_integrity}}% |
| 小红书 | {{xhs_events}} | {{xhs_processed}} | {{xhs_failed}} | {{xhs_lost}} | {{xhs_integrity}}% |

---

## 🔧 系统维护

### 自升级状态

- **当前版本**: {{current_version}}
- **最新版本**: {{latest_version}}
- **升级状态**: {{upgrade_status}}
- **最后升级时间**: {{last_upgrade}}

### 配置变更

{{#if config_changes.length > 0}}
| 时间 | 配置项 | 变更类型 | 操作人 |
|------|--------|----------|--------|
{{#each config_changes}}
| {{time}} | {{config_item}} | {{change_type}} | {{operator}} |
{{/each}}
{{else}}
✅ 今日无配置变更
{{/if}}

---

## 📝 问题与建议

### 已识别问题

{{#if issues.length > 0}}
{{#each issues}}
- **{{title}}**: {{description}}
  - 影响：{{impact}}
  - 建议：{{recommendation}}
{{/each}}
{{else}}
✅ 未识别重大问题
{{/if}}

### 优化建议

{{#if recommendations.length > 0}}
{{#each recommendations}}
- {{.}}
{{/each}}
{{else}}
✅ 系统运行良好，无需优化
{{/if}}

---

## 📈 趋势分析

### 7 日趋势

| 日期 | 任务成功率 | 发布成功率 | 告警数 |
|------|------------|------------|--------|
{{#each trend_7d}}
| {{date}} | {{task_rate}}% | {{publish_rate}}% | {{alerts}} |
{{/each}}

---

## ✅ 明日计划

- [ ] 检查系统资源使用情况
- [ ] 审查未解决告警
- [ ] 更新监控规则（如需要）
- [ ] 生成明日报告

---

*报告自动生成 | 如有疑问请联系系统管理员*
