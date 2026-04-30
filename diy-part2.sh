#!/bin/bash
#
# https://github.com/ByteJumper/OpenWrt-x86_64-firmware/edit/main/
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Version: 1.0
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.100.2/g' package/base-files/files/bin/config_generate

# Modify login password to be empty
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/OpenWrt/mRouter/g' package/base-files/files/bin/config_generate

if [ -d files ]; then
    chmod -R 755 files
fi

# ==========================================
# 清理不需要的包（优雅方案）
# ==========================================
echo "==> Cleaning unwanted packages..."

# passwall 全家桶
find feeds -type d -name "*passwall*" -exec rm -rf {} + 2>/dev/null

# autosamba（避免冲突）
find feeds -type d -name "autosamba" -exec rm -rf {} + 2>/dev/null

# 可选：清理代理内核（更干净）
rm -rf feeds/packages/net/{xray*,v2ray*,hysteria*,tuic*,naiveproxy*,shadowsocks*,shadow-tls*} 2>/dev/null

echo "==> Clean done"

# ===== 修复 gn 包编译问题 =====
echo "Applying gn package fix..."
# 查找 gn 的 Makefile
GN_MAKEFILE=$(find . -path "*/gn/Makefile" 2>/dev/null | head -1)

if [ -f "$GN_MAKEFILE" ]; then
    echo "Found gn Makefile: $GN_MAKEFILE"
    # 备份并修复
    cp "$GN_MAKEFILE" "$GN_MAKEFILE.bak"
    sed -i 's/+$(NINJA)/ninja/g' "$GN_MAKEFILE"
    echo "gn Makefile fixed"
else
    echo "gn Makefile not found - this may cause compilation issues"
fi
