#!/bin/bash
# ============================================
# Hermes Profile Backup Restore Script
# ============================================
# 用法: bash restore.sh [profile_name]
# 例如: bash restore.sh          # 恢复所有 profile
#       bash restore.sh aigp      # 只恢复 AIGP profile
#       bash restore.sh default   # 只恢复 default profile

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

echo "🔧 Hermes Profile Backup Restore"
echo "================================"
echo "备份源: $SCRIPT_DIR"
echo "目标:   $HERMES_HOME"
echo ""

# 检查 Hermes 是否已安装
if ! command -v hermes &> /dev/null; then
    echo "❌ Hermes 未安装！请先安装:"
    echo "   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
    exit 1
fi

# 恢复函数
restore_profile() {
    local profile_name=$1
    local src_dir="$SCRIPT_DIR/$profile_name"
    local dst_dir="$HERMES_HOME"
    
    if [ "$profile_name" != "default" ]; then
        dst_dir="$HERMES_HOME/profiles/$profile_name"
    fi
    
    if [ ! -d "$src_dir" ]; then
        echo "⚠️  未找到 $profile_name 的备份，跳过"
        return
    fi
    
    echo "📦 恢复 $profile_name..."
    
    # 创建目标目录
    mkdir -p "$dst_dir"
    
    # 复制配置文件
    if [ -f "$src_dir/config.yaml" ]; then
        cp "$src_dir/config.yaml" "$dst_dir/config.yaml"
        echo "   ✅ config.yaml"
    fi
    
    # 复制 SOUL.md
    if [ -f "$src_dir/SOUL.md" ]; then
        cp "$src_dir/SOUL.md" "$dst_dir/SOUL.md"
        echo "   ✅ SOUL.md"
    fi
    
    # 复制 skills
    if [ -d "$src_dir/skills" ]; then
        mkdir -p "$dst_dir/skills"
        cp -r "$src_dir/skills/"* "$dst_dir/skills/" 2>/dev/null || true
        local skill_count=$(find "$dst_dir/skills" -name "SKILL.md" | wc -l)
        echo "   ✅ skills/ ($skill_count 个 skill)"
    fi
    
    # 复制 .env 模板
    if [ -f "$src_dir/.env.template" ]; then
        if [ ! -f "$dst_dir/.env" ]; then
            cp "$src_dir/.env.template" "$dst_dir/.env"
            echo "   ⚠️  .env 模板已复制，请填入你的 API Key!"
        else
            echo "   ℹ️  .env 已存在，跳过（保留现有配置）"
        fi
    fi
    
    echo "   ✅ $profile_name 恢复完成!"
    echo ""
}

# 确定要恢复的 profile
if [ -n "$1" ]; then
    restore_profile "$1"
else
    echo "恢复所有 profile..."
    echo ""
    restore_profile "default"
    restore_profile "aigp"
fi

echo "================================"
echo "✅ 恢复完成!"
echo ""
echo "下一步:"
echo "  1. 编辑 .env 文件填入 API Key"
echo "     hermes config env-path  # 查看 .env 位置"
echo ""
echo "  2. 检查配置"
echo "     hermes doctor"
echo ""
echo "  3. 启动"
echo "     hermes          # 默认 profile"
echo "     aigp            # AIGP profile"
echo "     hermes -p aigp  # 或者用 -p 标志"
