#!/bin/bash
#
# version-checker.sh - 版本检测
# 负责检查当前版本和最新版本
#

# 配置
WORKSPACE_DIR="$HOME/OneDrive/Peach-Workspace"
VERSION_FILE="$WORKSPACE_DIR/.version"
GIT_REPO="$WORKSPACE_DIR"

# 获取当前版本
get_current_version() {
    # 优先从版本文件读取
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE" | tr -d '\n'
        return 0
    fi
    
    # 回退到 Git tag
    if command -v git &> /dev/null && [ -d "$GIT_REPO/.git" ]; then
        local tag=$(git -C "$GIT_REPO" describe --tags --abbrev=0 2>/dev/null)
        if [ -n "$tag" ]; then
            echo "$tag"
            return 0
        fi
        
        # 如果没有 tag，使用 commit hash
        local commit=$(git -C "$GIT_REPO" rev-parse --short HEAD 2>/dev/null)
        if [ -n "$commit" ]; then
            echo "dev-$commit"
            return 0
        fi
    fi
    
    # 默认版本
    echo "0.0.0-unknown"
}

# 获取最新版本
get_latest_version() {
    # 如果有远程 Git 仓库
    if command -v git &> /dev/null && [ -d "$GIT_REPO/.git" ]; then
        # 尝试获取远程 tags
        git -C "$GIT_REPO" fetch --tags 2>/dev/null || true
        local latest_tag=$(git -C "$GIT_REPO" tag --sort=-creatordate | head -n 1)
        if [ -n "$latest_tag" ]; then
            echo "$latest_tag"
            return 0
        fi
    fi
    
    # 如果没有 Git，检查版本文件（可能通过其他方式更新）
    # 这里可以扩展为检查远程配置文件
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE" | tr -d '\n'
        return 0
    fi
    
    # 默认返回当前版本（无更新）
    get_current_version
}

# 检查是否有新版本
has_new_version() {
    local current=$(get_current_version)
    local latest=$(get_latest_version)
    
    if [ "$current" != "$latest" ]; then
        return 0  # 有新版本
    else
        return 1  # 无新版本
    fi
}

# 比较版本号（支持 semver）
# 返回：0 = equal, 1 = v1 > v2, 2 = v1 < v2
compare_versions() {
    local v1="$1"
    local v2="$2"
    
    # 移除 'v' 前缀
    v1="${v1#v}"
    v2="${v2#v}"
    
    if [ "$v1" = "$v2" ]; then
        echo 0
        return 0
    fi
    
    # 使用 sort -V 进行比较
    local highest=$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | tail -n1)
    
    if [ "$highest" = "$v1" ]; then
        echo 1  # v1 > v2
    else
        echo 2  # v1 < v2
    fi
}

# 解析版本号组件
parse_version() {
    local version="$1"
    version="${version#v}"
    
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)
    local patch=$(echo "$version" | cut -d. -f3 | cut -d- -f1)
    
    echo "$major.$minor.$patch"
}

# 更新本地版本文件
update_version_file() {
    local version="$1"
    echo "$version" > "$VERSION_FILE"
}

# 如果直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "当前版本：$(get_current_version)"
    echo "最新版本：$(get_latest_version)"
    
    if has_new_version; then
        echo "状态：有新版本可用"
    else
        echo "状态：已是最新版本"
    fi
fi
