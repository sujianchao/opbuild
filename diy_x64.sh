# 设置默认语言
sed -i 's/lang auto/lang zh_cn/g' feeds/luci/modules/luci-base/root/etc/config/luci && echo "默认语言设置成功" || echo "默认语言设置失败"
#Lean tools
svn co --force -q https://github.com/coolsnowwolf/lede/trunk/tools ../tools && svn revert -R ../tools && mv ../tools/{ucl,upx} tools && sed -i 'N;30a\tools-y += ucl upx' tools/Makefile && rm -rf ../tools && echo "Lean tools添加成功" || echo "Lean tools添加失败"
#下载DIY包
git clone https://github.com/jsda/opdiy.git ../opdiy && mv -f ../opdiy/{lean,diy} package && echo "DIY包添加成功" || echo "DIY包添加失败"
#aria2 patch
#mv -f ../opdiy/patches/aria2/patches feeds/packages/net/aria2 && echo "aria2 patch添加成功" || echo "aria2 patch添加失败"
#adbyby规则更新
wget -O- https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > /tmp/dnsmasq.adblock && rm -rf package/lean/luci-app-adbyby-plus/root/usr/share/adbyby/dnsmasq.adblock && mv /tmp/dnsmasq.adblock package/lean/luci-app-adbyby-plus/root/usr/share/adbyby/dnsmasq.adblock && echo "Adblock Plus Host List更新成功" || echo "Adblock Plus Host List更新失败"
wget -O- https://adbyby.coding.net/p/xwhyc-rules/d/xwhyc-rules/git/raw/master/lazy.txt > /tmp/lazy.txt && rm -rf package/lean/adbyby/files/data/lazy.txt && mv /tmp/lazy.txt package/lean/adbyby/files/data/lazy.txt && echo "Lazy Rule更新成功" || echo "Lazy Rule更新失败"
wget -O- https://adbyby.coding.net/p/xwhyc-rules/d/xwhyc-rules/git/raw/master/video.txt > /tmp/video.txt && rm -rf package/lean/adbyby/files/data/video.txt && mv /tmp/video.txt package/lean/adbyby/files/data/video.txt && echo "Video Rule更新成功" || echo "Video Rule更新失败"
#更改default-settings
sed -i '/ustclug.org/d' package/lean/default-settings/files/zzz-default-settings
sed -i '/openwrt_release/d' package/lean/default-settings/files/zzz-default-settings
sed -i '/lib\/lua/d' package/lean/default-settings/files/zzz-default-settings
#其它
sed -i 's/net.netfilter.nf_conntrack_max=16384/net.netfilter.nf_conntrack_max=105535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
sed -i "s/bbr '0'/bbr '1'/g" package/*/luci-app-flowoffload/root/etc/config/flowoffload
sed -i "s/flow_offloading_hw '0'/flow_offloading_hw '1'/g" package/*/luci-app-flowoffload/root/etc/config/flowoffload
#包版本更新
getversion(){
curl -fsSL https://api.github.com/repos/$1/releases | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g' | sed 's/release-//g'
}
echo "V2ray v$(getversion v2ray/v2ray-core)"
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(getversion v2ray/v2ray-core)/g" package/lean/v2ray/Makefile
find package/lean/v2ray/ -maxdepth 2 -name "Makefile" | xargs -i sed -i "s/PKG_HASH:=.*/PKG_HASH:=skip/g" {}
#AdGuardHome
echo "AdGuardHome v$(getversion AdguardTeam/AdGuardHome)"
wget https://github.com/AdguardTeam/AdGuardHome/releases/download/v$(getversion AdguardTeam/AdGuardHome)/AdGuardHome_linux_amd64.tar.gz
tar -zxvf AdGuardHome*.tar.gz
rm -rf  AdGuardHome*.tar.gz AdGuardHome/{*.txt,*.md}
chmod +x AdGuardHome/AdGuardHome
mkdir -p files/usr/bin
mv -f AdGuardHome files/usr/bin
echo "/etc/AdGuardHome" >>  package/base-files/files/etc/sysupgrade.conf
#中文包修正
../convert_translation.sh
# 编译x64固件:
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
CONFIG_TARGET_IMAGES_GZIP=y
CONFIG_TARGET_ROOTFS_EXT4FS=y
CONFIG_TARGET_ROOTFS_TARGZ=y
CONFIG_PACKAGE_kmod-kvm-amd=y
CONFIG_PACKAGE_kmod-kvm-intel=y
CONFIG_PACKAGE_kmod-kvm-x86=y
CONFIG_TESTING_KERNEL=y
#
#OpenWrt中文包
CONFIG_LUCI_LANG_zh_Hans=y
#
# Image Options
#
#内核分区大小MB
CONFIG_TARGET_KERNEL_PARTSIZE=32
#硬盘空间大小MB
CONFIG_TARGET_ROOTFS_PARTSIZE=256
#GRUB启动等待时间
CONFIG_GRUB_TIMEOUT="1"
#GRUB启动显示名称
#CONFIG_GRUB_TITLE="OpenWrt"
EOF
# 编译UEFI固件:
# cat >> .config <<EOF
# CONFIG_EFI_IMAGES=y
# EOF
# IPv6支持:
cat >> .config <<EOF
# IPv6支持:
CONFIG_IPV6=y
CONFIG_KERNEL_IPV6=y
CONFIG_PACKAGE_ip6tables=y
CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcpd-ipv6only=y
CONFIG_PACKAGE_kmod-ip6tables=y
CONFIG_PACKAGE_kmod-nf-ipt6=y
CONFIG_PACKAGE_kmod-nf-conntrack6=y
CONFIG_PACKAGE_luci-proto-ipv6=y
EOF
# 多文件系统支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-fs-nfs=y
# CONFIG_PACKAGE_kmod-fs-nfs-common=y
# CONFIG_PACKAGE_kmod-fs-nfs-v3=y
# CONFIG_PACKAGE_kmod-fs-nfs-v4=y
# CONFIG_PACKAGE_kmod-fs-ntfs=y
# CONFIG_PACKAGE_kmod-fs-squashfs=y
# EOF
# USB3.0支持:
cat >> .config <<EOF
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb2-pci=y
CONFIG_PACKAGE_kmod-usb3=y
EOF
# 常用LuCI插件选择:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-accesscontrol=y
CONFIG_PACKAGE_luci-app-adbyby-plus=y
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-advanced-reboot=y
CONFIG_PACKAGE_luci-app-autoreboot=y
CONFIG_PACKAGE_luci-app-banip=y
CONFIG_PACKAGE_luci-app-commands=y
CONFIG_PACKAGE_luci-app-diag-core=y
CONFIG_PACKAGE_luci-app-filetransfer=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-nlbwmon=y
CONFIG_PACKAGE_luci-app-openvpn=y
CONFIG_PACKAGE_luci-app-openvpn-server=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-app-ssr-plus=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Socks=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Simple_obfs=y
CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin=y
CONFIG_PACKAGE_luci-app-flowoffload=y
CONFIG_PACKAGE_luci-app-v2ray-server=y
CONFIG_PACKAGE_luci-app-haproxy-tcp=y
CONFIG_PACKAGE_strongswan=y
CONFIG_PACKAGE_luci-app-ipsec-vpnd=y
CONFIG_PACKAGE_luci-app-mwan3helper=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-nps=y
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_socks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_socks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs=y
CONFIG_PACKAGE_dnsforwarder=y
CONFIG_PACKAGE_luci-app-statistics=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-uhttpd=y
#CONFIG_PACKAGE_luci-app-unblockmusic=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-vlmcsd=y
CONFIG_PACKAGE_luci-app-vnstat=y
CONFIG_PACKAGE_luci-app-wol=y
# CONFIG_PACKAGE_luci-app-xlnetacc=y
CONFIG_PACKAGE_luci-base=y
# CONFIG_PACKAGE_luci-app-aria2=y
# CONFIG_PACKAGE_luci-app-baidupcs-web=y
# CONFIG_PACKAGE_luci-app-docker=y
# CONFIG_PACKAGE_luci-app-frpc=y
# CONFIG_PACKAGE_luci-app-kodexplorer=y
# CONFIG_PACKAGE_luci-app-minidlna=y
# CONFIG_PACKAGE_luci-app-qbittorrent=y
# CONFIG_PACKAGE_luci-app-verysync=y
# CONFIG_PACKAGE_luci-app-wireguard=y
# CONFIG_PACKAGE_luci-app-wrtbwmon=y
EOF
# LuCI主题:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-theme-bootstrap=y
#CONFIG_PACKAGE_luci-theme-material=y
EOF
# 常用软件包:
cat >> .config <<EOF
#CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_default-settings=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_ddns-scripts=y
CONFIG_PACKAGE_ddns-scripts_aliyun=y
CONFIG_PACKAGE_ddns-scripts_cloudflare.com-v4=y
CONFIG_PACKAGE_ddns-scripts_dnspod=y
CONFIG_PACKAGE_ddns-scripts_freedns_42_pl=y
CONFIG_PACKAGE_ddns-scripts_godaddy.com-v1=y
CONFIG_PACKAGE_ddns-scripts_no-ip_com=y
CONFIG_PACKAGE_ddns-scripts_nsupdate=y
# CONFIG_PACKAGE_dnsmasq is not set
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_bind-dig=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_kmod-tcp-bbr=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_screen=y
CONFIG_PACKAGE_tree=y
CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y
#CONFIG_PACKAGE_qemu-ga=y
CONFIG_PACKAGE_gzip=y
CONFIG_PACKAGE_unrar=y
CONFIG_PACKAGE_unzip=y
CONFIG_PACKAGE_zip=y
CONFIG_PACKAGE_xz-utils=y
CONFIG_PACKAGE_virtio-console-helper=y
CONFIG_PACKAGE_vnstat=y
CONFIG_PACKAGE_vnstati=y
CONFIG_PACKAGE_openssh-sftp-server=y
EOF
# 取消编译VMware镜像以及镜像填充 (不要删除被缩进的注释符号):
cat >> .config <<EOF
CONFIG_VDI_IMAGES=y
CONFIG_VMDK_IMAGES=y
EOF
