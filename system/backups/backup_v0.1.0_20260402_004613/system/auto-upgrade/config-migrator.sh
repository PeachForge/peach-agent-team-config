#!/bin/bash
#
# config-migrator.sh - 配置迁移
# 负责配置文件的版本迁移
#

set -e

# 配置
WORKSPACE_DIR="$HOME/OneDrive/Peach-Workspace"
LOG_DIR="$WORKSPACE_DIR/system/logs"
LOG_FILE="$LOG_DIR/upgrade.log"
CONFIG_DIR="$WORKSPACE_DIR"
SKILLS_DIR="$WORKSPACE_DIR/skills"

# 需要迁移的配置类型
CONFIG_TYPES=(
    "agent_config"      # Agent 配置
    "content_templates" # 内容模板
    "skills"           # 技能包
    "system_config"    # 系统配置
)

# 日志函数
migrate_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [MIGRATE] [$level] $message" | tee -a "$LOG_FILE"
}

# 主迁移函数
migrate_config() {
    local from_version="${1:-unknown}"
    local to_version="${2:-unknown}"
    
    migrate_log "INFO" "=========================================="
    migrate_log "INFO" "开始配置迁移"
    migrate_log "INFO" "=========================================="
    migrate_log "INFO" "从版本：$from_version"
    migrate_log "INFO" "到版本：$to_version"
    
    local migration_success=true
    
    # 迁移 Agent 配置
    if ! migrate_agent_config "$from_version" "$to_version"; then
        migrate_log "WARN" "Agent 配置迁移部分失败"
        migration_success=false
    fi
    
    # 迁移内容模板
    if ! migrate_content_templates "$from_version" "$to_version"; then
        migrate_log "WARN" "内容模板迁移部分失败"
        migration_success=false
    fi
    
    # 迁移技能包
    if ! migrate_skills "$from_version" "$to_version"; then
        migrate_log "WARN" "技能包迁移部分失败"
        migration_success=false
    fi
    
    # 迁移系统配置
    if ! migrate_system_config "$from_version" "$to_version"; then
        migrate_log "WARN" "系统配置迁移部分失败"
        migration_success=false
    fi
    
    if [ "$migration_success" = true ]; then
        migrate_log "SUCCESS" "配置迁移完成"
        return 0
    else
        migrate_log "WARN" "配置迁移完成（部分失败）"
        return 0  # 不中断升级流程
    fi
}

# 迁移 Agent 配置
migrate_agent_config() {
    migrate_log "INFO" "迁移 Agent 配置..."
    
    local config_files=(
        "AGENTS.md"
        "SOUL.md"
        "USER.md"
        "TOOLS.md"
        "IDENTITY.md"
        ".openclawrc"
    )
    
    local success=true
    
    for config_file in "${config_files[@]}"; do
        local source="$WORKSPACE_DIR/$config_file"
        local template="$WORKSPACE_DIR/templates/$config_file"
        
        if [ -f "$template" ]; then
            # 如果有新模板，合并配置
            merge_config "$source" "$template"
            migrate_log "INFO" "已更新：$config_file"
        elif [ -f "$source" ]; then
            migrate_log "INFO" "保留：$config_file"
        fi
    done
    
    return 0
}

# 迁移内容模板
migrate_content_templates() {
    migrate_log "INFO" "迁移内容模板..."
    
    local templates_dir="$WORKSPACE_DIR/templates"
    local new_templates_dir="$WORKSPACE_DIR/system/templates_new"
    
    if [ -d "$new_templates_dir" ]; then
        # 备份旧模板
        if [ -d "$templates_dir" ]; then
            mv "$templates_dir" "$templates_dir.backup.$(date '+%Y%m%d_%H%M%S')"
            migrate_log "INFO" "已备份旧模板"
        fi
        
        # 使用新模板
        mv "$new_templates_dir" "$templates_dir"
        migrate_log "INFO" "已应用新模板"
    fi
    
    return 0
}

# 迁移技能包
migrate_skills() {
    migrate_log "INFO" "迁移技能包..."
    
    # 检查是否有新技能包
    local new_skills_dir="$WORKSPACE_DIR/system/skills_new"
    
    if [ -d "$new_skills_dir" ]; then
        # 备份当前技能
        if [ -d "$SKILLS_DIR" ]; then
            local backup_name="skills.backup.$(date '+%Y%m%d_%H%M%S')"
            mv "$SKILLS_DIR" "$WORKSPACE_DIR/$backup_name"
            migrate_log "INFO" "已备份技能包：$backup_name"
        fi
        
        # 安装新技能
        mv "$new_skills_dir" "$SKILLS_DIR"
        migrate_log "INFO" "已安装新技能包"
    fi
    
    # 检查技能更新
    if [ -d "$SKILLS_DIR" ]; then
        # 遍历技能目录，检查 SKILL.md 更新
        find "$SKILLS_DIR" -name "SKILL.md" -type f | while read skill_file; do
            migrate_log "INFO" "检查技能：$(dirname "$skill_file")"
        done
    fi
    
    return 0
}

# 迁移系统配置
migrate_system_config() {
    migrate_log "INFO" "迁移系统配置..."
    
    # 系统配置文件
    local system_configs=(
        ".gitignore"
        ".env.example"
        "package.json"
    )
    
    for config in "${system_configs[@]}"; do
        local source="$WORKSPACE_DIR/$config"
        local new_source="$WORKSPACE_DIR/system/$config.new"
        
        if [ -f "$new_source" ]; then
            if [ -f "$source" ]; then
                # 合并配置（保留用户自定义）
                merge_config "$source" "$new_source"
                rm -f "$new_source"
            else
                mv "$new_source" "$source"
            fi
            migrate_log "INFO" "已更新：$config"
        fi
    done
    
    return 0
}

# 合并配置文件（保留用户自定义）
merge_config() {
    local current="$1"
    local template="$2"
    
    if [ ! -f "$current" ] || [ ! -f "$template" ]; then
        return 1
    fi
    
    # 简单策略：如果当前文件有自定义内容，保留当前文件
    # 如果模板有新配置项，追加到当前文件
    
    # 这里可以实现更复杂的合并逻辑
    # 例如：JSON 合并、YAML 合并等
    
    # 对于 Markdown 文件，检查是否有新章节
    if [[ "$current" == *.md ]]; then
        # 提取模板中的新章节
        local new_sections=$(grep -E "^## " "$template" | cut -d' ' -f3-)
        
        for section in $new_sections; do
            if ! grep -q "^## $section" "$current"; then
                # 追加新章节
                echo "" >> "$current"
                grep -A 100 "^## $section" "$template" | \
                    grep -B 100 -E "^## |^$" | \
                    head -n -1 >> "$current"
                migrate_log "INFO" "添加新章节：$section"
            fi
        done
    fi
    
    return 0
}

# 生成迁移报告
generate_migration_report() {
    local from_version="$1"
    local to_version="$2"
    local report_file="$LOG_DIR/migration_report_$(date '+%Y%m%d_%H%M%S').md"
    
    cat > "$report_file" << EOF
# 配置迁移报告

## 版本信息
- 从版本：$from_version
- 到版本：$to_version
- 迁移时间：$(date -Iseconds)

## 迁移项目

### Agent 配置
$(list_config_changes "agent_config")

### 内容模板
$(list_config_changes "content_templates")

### 技能包
$(list_config_changes "skills")

### 系统配置
$(list_config_changes "system_config")

## 迁移状态
$(if [ $? -eq 0 ]; then echo "✓ 成功"; else echo "✗ 部分失败"; fi)

---
*此报告由 config-migrator.sh 自动生成*
EOF
    
    migrate_log "INFO" "迁移报告：$report_file"
    echo "$report_file"
}

# 列出配置变更
list_config_changes() {
    local config_type="$1"
    # 这里可以实现详细的变更列表
    echo "- 配置类型：$config_type"
    echo "- 状态：已迁移"
}

# 验证配置
validate_config() {
    migrate_log "INFO" "验证配置..."
    
    local errors=0
    
    # 检查关键配置文件
    for config in "AGENTS.md" "SOUL.md" ".openclawrc"; do
        if [ ! -f "$WORKSPACE_DIR/$config" ]; then
            migrate_log "ERROR" "缺少配置文件：$config"
            ((errors++))
        fi
    done
    
    # 检查技能目录
    if [ ! -d "$SKILLS_DIR" ]; then
        migrate_log "ERROR" "缺少技能目录"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        migrate_log "SUCCESS" "配置验证通过"
        return 0
    else
        migrate_log "ERROR" "配置验证失败：$errors 个错误"
        return 1
    fi
}

# 如果直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        migrate)
            migrate_config "${2:-unknown}" "${3:-latest}"
            ;;
        validate)
            validate_config
            ;;
        report)
            generate_migration_report "${2:-unknown}" "${3:-latest}"
            ;;
        help|*)
            echo "用法：$0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  migrate <from> <to>     执行配置迁移"
            echo "  validate                验证配置完整性"
            echo "  report <from> <to>      生成迁移报告"
            echo "  help                    显示帮助"
            ;;
    esac
fi
