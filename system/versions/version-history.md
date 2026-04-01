# 版本历史 (Version History)

## 当前版本

- **版本**: v0.1.0
- **发布日期**: 2026-04-02
- **状态**: Stable

---

## v0.1.0 (2026-04-02) - 初始版本

### 新增功能

#### 核心升级系统
- ✅ 升级管理器 (`upgrade-manager.sh`)
  - 完整的升级流程编排
  - 支持强制升级模式
  - 升级状态查询
  
- ✅ 版本检测器 (`version-checker.sh`)
  - Git tag 版本检测
  - 配置文件版本检测
  - 语义化版本比较
  
- ✅ 备份管理器 (`backup-manager.sh`)
  - 自动备份关键文件
  - 备份完整性校验
  - 备份恢复功能
  - 自动清理旧备份（保留最近 3 个）
  
- ✅ 回滚管理器 (`rollback-manager.sh`)
  - 手动回滚支持
  - 自动回滚触发
  - 回滚历史记录
  - 告警通知机制
  
- ✅ 配置迁移器 (`config-migrator.sh`)
  - Agent 配置迁移
  - 内容模板迁移
  - 技能包迁移
  - 系统配置合并
  
- ✅ 健康检查器 (`health-checker.sh`)
  - 文件完整性检查
  - 配置有效性验证
  - 技能包加载检查
  - Git 状态检查
  - 权限检查
  - 磁盘空间检查

### 目录结构

```
system/
├── auto-upgrade/           # 升级脚本
│   ├── upgrade-manager.sh
│   ├── version-checker.sh
│   ├── backup-manager.sh
│   ├── rollback-manager.sh
│   ├── config-migrator.sh
│   └── health-checker.sh
├── versions/               # 版本信息
│   └── version-history.md
├── logs/                   # 日志目录
│   ├── upgrade.log
│   ├── health_report_*.md
│   └── migration_report_*.md
└── backups/                # 备份目录（自动生成）
    └── backup_*_*/
```

### 升级流程

1. **检查新版本** - 通过 Git tag 或配置文件检测
2. **备份当前版本** - 创建完整备份并验证
3. **下载新版本** - 获取新版本文件
4. **迁移配置** - 合并用户配置与新配置
5. **验证升级** - 运行健康检查
6. **清理旧备份** - 保留最近 3 个备份

### 回滚流程

1. **检测失败** - 升级失败自动触发
2. **恢复备份** - 恢复最近的可用备份
3. **记录原因** - 记录失败原因到日志
4. **发送告警** - 通知用户升级失败

### 使用方法

```bash
# 检查更新
./upgrade-manager.sh check

# 执行升级
./upgrade-manager.sh upgrade

# 强制升级
./upgrade-manager.sh upgrade --force

# 回滚到上一版本
./upgrade-manager.sh rollback

# 查看状态
./upgrade-manager.sh status

# 运行健康检查
./health-checker.sh check
```

### 配置迁移策略

- **Agent 配置** - 保留用户自定义，追加新配置项
- **内容模板** - 完整替换（旧模板备份）
- **技能包** - 完整替换（旧技能备份）
- **系统配置** - 智能合并，保留用户修改

### 安全特性

- ✅ 升级前自动备份
- ✅ 备份完整性校验（MD5）
- ✅ 升级失败自动回滚
- ✅ 保留多个备份版本
- ✅ 详细的升级日志
- ✅ 健康检查验证

---

## 计划中的版本

### v0.2.0 (计划中)

- [ ] 支持远程配置源
- [ ] 增量更新支持
- [ ] 升级进度显示
- [ ] 邮件/消息通知集成
- [ ] 定时自动升级检查
- [ ] 升级预览功能

### v1.0.0 (未来)

- [ ] 生产环境就绪
- [ ] 完整的错误恢复
- [ ] 性能优化
- [ ] 文档完善

---

## 升级日志位置

- 主日志：`logs/upgrade.log`
- 健康报告：`logs/health_report_*.md`
- 迁移报告：`logs/migration_report_*.md`
- 告警日志：`logs/rollback_alerts.log`
- 严重告警：`logs/critical_alerts.log`

---

## 备份管理

- 备份位置：`system/backups/`
- 保留策略：最近 3 个备份
- 备份内容：
  - 升级脚本
  - 版本信息
  - 配置文件
  - 技能包
  - 内存文件

---

*最后更新：2026-04-02*
*维护者：Peach System*
