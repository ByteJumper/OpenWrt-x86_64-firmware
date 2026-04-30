#!/bin/bash
#
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Version: 1.1 (Stable & Maintainable)
#

echo "==> DIY Part 2 Start"

# ==========================================
# 基础系统定制
# ==========================================

# 修改默认IP
sed -i 's/192.168.1.1/192.168.100.2/g' package/base-files/files/bin/config_generate

# 设置空密码
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

# 修改主机名
sed -i 's/OpenWrt/mRouter/g' package/base-files/files/bin/config_generate

# 文件权限
[ -d files ] && chmod -R 755 files

# ==========================================
# 精准清理不需要的包（核心优化）
# ==========================================
echo "==> Cleaning unwanted packages..."

# ❌ Passwall 相关（避免 warning + 无用依赖）
rm -rf feeds/luci/applications/luci-app-passwall* 2>/dev/null
rm -rf feeds/packages/net/{passwall*,xray*,v2ray*,hysteria*,tuic*,naiveproxy*,shadow-tls*} 2>/dev/null

# ❌ autosamba（避免与 samba4 冲突）
rm -rf feeds/luci/applications/luci-app-autosamba 2>/dev/null
rm -rf feeds/packages/utils/autosamba 2>/dev/null

echo "==> Clean done"

# ==========================================
# gn 编译修复（兼容不同版本）
# ==========================================
echo "==> Applying gn fix..."

GN_MAKEFILE=$(find . -path "*/gn/Makefile" 2>/dev/null | head -1)

if [ -f "$GN_MAKEFILE" ]; then
    echo "Found gn Makefile: $GN_MAKEFILE"
    grep -q '+$(NINJA)' "$GN_MAKEFILE" && sed -i 's/\+$(NINJA)/ninja/g' "$GN_MAKEFILE"
    echo "gn fix applied"
else
    echo "gn Makefile not found (skip)"
fi

# ==========================================
# 收敛配置（防止删包后残留依赖）
# ==========================================
echo "==> Running defconfig..."
make defconfig

echo "==> DIY Part 2 Done"
