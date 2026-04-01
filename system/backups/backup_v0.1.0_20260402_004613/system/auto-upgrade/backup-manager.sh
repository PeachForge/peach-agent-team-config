#!/bin/bash
#
# backup-manager.sh - 备份管理
# 负责创建和恢复系统备份
#

set -e

# 配置
WORKSPACE_DIR="$HOME/OneDrive/Peach-Workspace"
BACKUP_DIR="$WORKSPACE_DIR/system/backups"
LOG_DIR="$WORKSPACE_DIR/system/logs"
LOG_FILE="$LOG_DIR/upgrade.log"

# 需要备份的目录和文件
BACKUP_ITEMS=(
    "system/auto-upgrade"
    "system/versions"
    ".version"
    ".openclawrc"
    "AGENTS.md"
    "SOUL.md"
    "USER.md"
    "TOOLS.md"
    "skills"
    "memory"
)

# 日志函数
backup_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [BACKUP] [$level] $message" | tee -a "$LOG_FILE"
}

# 创建备份
create_backup() {
    local version="${1:-unknown}"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_id="backup_${version}_${timestamp}"
    local backup_path="$BACKUP_DIR/$backup_id"
    
    backup_log "INFO" "开始创建备份：$backup_id"
    
    # 创建备份目录
    mkdir -p "$backup_path"
    
    # 创建备份清单
    local manifest="$backup_path/manifest.json"
    echo "{" > "$manifest"
    echo "  \"backup_id\": \"$backup_id\"," >> "$manifest"
    echo "  \"version\": \"$version\"," >> "$manifest"
    echo "  \"timestamp\": \"$(date -Iseconds)\"," >> "$manifest"
    echo "  \"items\": [" >> "$manifest"
    
    local first=true
    for item in "${BACKUP_ITEMS[@]}"; do
        local source_path="$WORKSPACE_DIR/$item"
        
        if [ -e "$source_path" ]; then
            local dest_path="$backup_path/$item"
            local dest_dir=$(dirname "$dest_path")
            
            mkdir -p "$dest_dir"
            
            if [ -d "$source_path" ]; then
                cp -r "$source_path" "$dest_path"
            else
                cp "$source_path" "$dest_path"
            fi
            
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "$manifest"
            fi
            echo -n "    \"$item\"" >> "$manifest"
            
            backup_log "INFO" "备份：$item"
        else
            backup_log "WARN" "跳过（不存在）: $item"
        fi
    done
    
    echo "" >> "$manifest"
    echo "  ]" >> "$manifest"
    echo "}" >> "$manifest"
    
    # 创建校验和文件
    find "$backup_path" -type f -name "*.sh" -o -name "*.md" -o -name "*.json" 2>/dev/null | \
        while read file; do
            md5sum "$file" >> "$backup_path/checksums.md5" 2>/dev/null || true
        done
    
    backup_log "SUCCESS" "备份创建完成：$backup_id"
    echo "$backup_id"
    return 0
}

# 恢复备份
restore_backup() {
    local backup_id="$1"
    local backup_path="$BACKUP_DIR/$backup_id"
    
    if [ ! -d "$backup_path" ]; then
        backup_log "ERROR" "备份不存在：$backup_id"
        return 1
    fi
    
    backup_log "INFO" "开始恢复备份：$backup_id"
    
    # 验证备份完整性
    if [ -f "$backup_path/checksums.md5" ]; then
        backup_log "INFO" "验证备份完整性..."
        cd "$backup_path"
        if ! md5sum -c checksums.md5 --quiet 2>/dev/null; then
            backup_log "WARN" "备份校验和验证失败，继续恢复..."
        fi
        cd - > /dev/null
    fi
    
    # 读取备份清单
    local manifest="$backup_path/manifest.json"
    if [ -f "$manifest" ]; then
        # 提取备份项（简单解析 JSON）
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
                    
                    backup_log "INFO" "恢复：$item"
                fi
            done
    else
        # 如果没有清单，尝试恢复所有目录
        for item in "${BACKUP_ITEMS[@]}"; do
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
                
                backup_log "INFO" "恢复：$item"
            fi
        done
    fi
    
    backup_log "SUCCESS" "备份恢复完成：$backup_id"
    return 0
}

# 获取最新备份
get_latest_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        ls -1t "$BACKUP_DIR" 2>/dev/null | head -n 1
    fi
}

# 列出所有备份
list_backups() {
    if [ -d "$BACKUP_DIR" ]; then
        echo "可用备份:"
        ls -1t "$BACKUP_DIR" 2>/dev/null | while read backup; do
            local manifest="$BACKUP_DIR/$backup/manifest.json"
            local version="unknown"
            local timestamp="unknown"
            
            if [ -f "$manifest" ]; then
                version=$(grep '"version"' "$manifest" | cut -d'"' -f4)
                timestamp=$(grep '"timestamp"' "$manifest" | cut -d'"' -f4)
            fi
            
            echo "  - $backup (版本：$version, 时间：$timestamp)"
        done
    else
        echo "无备份"
    fi
}

# 删除备份
delete_backup() {
    local backup_id="$1"
    local backup_path="$BACKUP_DIR/$backup_id"
    
    if [ -d "$backup_path" ]; then
        rm -rf "$backup_path"
        backup_log "INFO" "删除备份：$backup_id"
        echo "备份已删除：$backup_id"
    else
        backup_log "ERROR" "备份不存在：$backup_id"
        return 1
    fi
}

# 验证备份
verify_backup() {
    local backup_id="$1"
    local backup_path="$BACKUP_DIR/$backup_id"
    
    if [ ! -d "$backup_path" ]; then
        echo "备份不存在：$backup_id"
        return 1
    fi
    
    echo "验证备份：$backup_id"
    
    if [ -f "$backup_path/checksums.md5" ]; then
        cd "$backup_path"
        if md5sum -c checksums.md5 --quiet 2>/dev/null; then
            echo "✓ 校验和验证通过"
        else
            echo "✗ 校验和验证失败"
            return 1
        fi
        cd - > /dev/null
    else
        echo "! 无校验和文件"
    fi
    
    if [ -f "$backup_path/manifest.json" ]; then
        echo "✓ 备份清单存在"
    else
        echo "! 无备份清单"
    fi
    
    echo "备份验证完成"
    return 0
}

# 如果直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-list}" in
        create)
            create_backup "${2:-unknown}"
            ;;
        restore)
            restore_backup "$2"
            ;;
        list)
            list_backups
            ;;
        latest)
            get_latest_backup
            ;;
        delete)
            delete_backup "$2"
            ;;
        verify)
            verify_backup "$2"
            ;;
        *)
            echo "用法：$0 <command> [options]"
            echo ""
            echo "命令:"
            echo "  create [version]     创建备份"
            echo "  restore <backup_id>  恢复备份"
            echo "  list                 列出所有备份"
            echo "  latest               显示最新备份 ID"
            echo "  delete <backup_id>   删除备份"
            echo "  verify <backup_id>   验证备份"
            ;;
    esac
fi
