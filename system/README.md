# 系统自升级系统 (Auto-Upgrade System)

## 概述

这是一个完整的系统自升级架构，支持 Git 版本控制、配置迁移、备份回滚和健康检查。

## 目录结构

```
system/
├── auto-upgrade/           # 升级脚本目录
│   ├── upgrade-manager.sh  # 主升级管理器
│   ├── version-checker.sh  # 版本检测
│   ├── backup-manager.sh   # 备份管理
│   ├── rollback-manager.sh # 回滚管理
│   ├── config-migrator.sh  # 配置迁移
│   └── health-checker.sh   # 健康检查
├── versions/               # 版本信息
│   └── version-history.md  # 版本历史
├── logs/                   # 日志目录
│   ├── upgrade.log         # 升级日志
│   └── ...                 # 其他日志
└── backups/                # 备份目录（自动生成）
```

## 快速开始

### 检查更新

```bash
cd ~/OneDrive/Peach-Workspace/system/auto-upgrade
./upgrade-manager.sh check
```

### 执行升级

```bash
# 普通升级（仅当有新版本时）
./upgrade-manager.sh upgrade

# 强制升级（即使版本相同）
./upgrade-manager.sh upgrade --force
```

### 回滚

```bash
# 回滚到上一个版本
./upgrade-manager.sh rollback

# 回滚到指定备份
./upgrade-manager.sh rollback backup_v0.1.0_20260402_120000
```

### 查看状态

```bash
./upgrade-manager.sh status
```

### 健康检查

```bash
./health-checker.sh check
```

## 升级流程

```
1. 检查新版本
   └─> 通过 Git tag 或配置文件检测

2. 备份当前版本
   └─> 创建完整备份
   └─> 生成校验和
   └─> 验证备份完整性

3. 下载新版本
   └─> 获取新版本文件
   └─> 验证文件完整性

4. 迁移配置
   └─> Agent 配置（智能合并）
   └─> 内容模板（替换 + 备份）
   └─> 技能包（替换 + 备份）
   └─> 系统配置（合并）

5. 验证升级
   └─> 文件完整性检查
   └─> 配置有效性验证
   └─> 技能包加载检查
   └─> Git 状态检查
   └─> 权限检查
   └─> 磁盘空间检查

6. 清理旧备份
   └─> 保留最近 3 个备份
```

## 回滚流程

```
1. 检测升级失败
   └─> 健康检查失败自动触发

2. 恢复最近备份
   └─> 自动选择最新备份
   └─> 或手动指定备份 ID

3. 记录失败原因
   └─> 写入升级日志
   └─> 生成回滚记录

4. 发送告警
   └─> 记录告警日志
   └─> 可扩展消息通知
```

## 备份管理

### 创建备份

```bash
./backup-manager.sh create [version]
```

### 列出备份

```bash
./backup-manager.sh list
```

### 恢复备份

```bash
./backup-manager.sh restore <backup_id>
```

### 验证备份

```bash
./backup-manager.sh verify <backup_id>
```

### 删除备份

```bash
./backup-manager.sh delete <backup_id>
```

## 配置迁移

### 支持的配置类型

1. **Agent 配置** (`AGENTS.md`, `SOUL.md`, `USER.md`, etc.)
   - 策略：保留用户自定义，追加新配置项

2. **内容模板** (`templates/`)
   - 策略：完整替换，旧模板备份

3. **技能包** (`skills/`)
   - 策略：完整替换，旧技能备份

4. **系统配置** (`.openclawrc`, etc.)
   - 策略：智能合并，保留用户修改

### 生成迁移报告

```bash
./config-migrator.sh report <from_version> <to_version>
```

## 健康检查

### 检查项目

- ✅ 文件完整性
- ✅ 配置有效性
- ✅ 技能包加载
- ✅ Git 状态
- ✅ 权限检查
- ✅ 磁盘空间

### 运行检查

```bash
./health-checker.sh check
```

### 查看状态

```bash
./health-checker.sh status
```

## 日志系统

### 日志位置

- **升级日志**: `logs/upgrade.log`
- **健康报告**: `logs/health_report_*.md`
- **迁移报告**: `logs/migration_report_*.md`
- **回滚告警**: `logs/rollback_alerts.log`
- **严重告警**: `logs/critical_alerts.log`

### 查看日志

```bash
# 查看最近日志
tail -n 50 logs/upgrade.log

# 查看完整日志
cat logs/upgrade.log

# 查看健康报告
ls -lt logs/health_report_*.md
```

## 版本管理

### 查看版本历史

```bash
cat versions/version-history.md
```

### 更新版本号

```bash
echo "v0.2.0" > ~/.openclaw/workspace/.version
```

### 版本检测

```bash
./version-checker.sh
```

## 安全特性

- ✅ **自动备份**: 升级前自动创建完整备份
- ✅ **完整性校验**: MD5 校验和验证
- ✅ **自动回滚**: 升级失败自动恢复
- ✅ **多版本保留**: 保留最近 3 个备份
- ✅ **详细日志**: 完整的升级过程记录
- ✅ **健康验证**: 升级后自动验证

## 故障排除

### 升级失败

1. 查看日志：`tail -n 100 logs/upgrade.log`
2. 自动回滚应该已经触发
3. 检查回滚记录：`./rollback-manager.sh history`

### 手动回滚

```bash
# 列出可用备份
./backup-manager.sh list

# 恢复到指定备份
./rollback-manager.sh rollback <backup_id>
```

### 健康检查失败

1. 查看健康报告：`ls -lt logs/health_report_*.md`
2. 根据失败项目修复
3. 重新运行检查：`./health-checker.sh check`

## 高级用法

### 自定义备份项

编辑 `backup-manager.sh` 中的 `BACKUP_ITEMS` 数组：

```bash
BACKUP_ITEMS=(
    "system/auto-upgrade"
    "system/versions"
    ".version"
    # 添加你的自定义项
    "my-custom-config"
)
```

### 自定义健康检查

编辑 `health-checker.sh` 中的 `HEALTH_CHECKS` 数组：

```bash
HEALTH_CHECKS=(
    "file_integrity"
    "config_valid"
    # 添加你的自定义检查
    "my_custom_check"
)
```

### 集成消息通知

在 `rollback-manager.sh` 的 `send_rollback_alert()` 函数中添加：

```bash
# 示例：发送 Telegram 消息
send_telegram_message "系统已回滚到 $backup_id，原因：$reason"
```

## 最佳实践

1. **定期备份**: 重要操作前手动创建备份
2. **检查日志**: 升级后查看日志确认成功
3. **测试回滚**: 定期测试回滚功能确保可用
4. **保留空间**: 确保磁盘有足够空间（至少 100MB）
5. **版本记录**: 每次升级后更新版本历史

## 技术支持

- 查看版本历史：`versions/version-history.md`
- 查看升级日志：`logs/upgrade.log`
- 报告问题：记录详细错误信息和日志

---

*最后更新：2026-04-02*
*版本：v0.1.0*
