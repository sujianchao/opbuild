sed -i 's/tplink-8mlzma/tplink-16mlzma/' target/linux/ar71xx/image/generic-tp-link.mk
wget -qO- https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > /tmp/dnsmasq.adblock && rm -rf package/lean/luci-app-adbyby-plus/root/usr/share/adbyby/dnsmasq.adblock && mv /tmp/dnsmasq.adblock package/lean/luci-app-adbyby-plus/root/usr/share/adbyby/dnsmasq.adblock && echo "Adblock Plus Host List更新成功" || echo "Adblock Plus Host List更新失败"
wget -qO- https://adbyby.coding.net/p/xwhyc-rules/d/xwhyc-rules/git/raw/master/lazy.txt > /tmp/lazy.txt && rm -rf package/lean/adbyby/files/data/lazy.txt && mv /tmp/lazy.txt package/lean/adbyby/files/data/lazy.txt && echo "Lazy Rule更新成功" || echo "Lazy Rule更新失败"
wget -qO- https://adbyby.coding.net/p/xwhyc-rules/d/xwhyc-rules/git/raw/master/video.txt > /tmp/video.txt && rm -rf package/lean/adbyby/files/data/video.txt && mv /tmp/video.txt package/lean/adbyby/files/data/video.txt && echo "Video Rule更新成功" || echo "Video Rule更新失败"
#更改default-settings
sed -i '/ustclug.org/d' package/lean/default-settings/files/zzz-default-settings
#其它
sed -i 's/net.netfilter.nf_conntrack_max=16384/net.netfilter.nf_conntrack_max=105535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
sed -i "s/bbr '0'/bbr '1'/g" package/*/luci-app-sfe/root/etc/config/sfe
sed -i "s/wifi '0'/wifi '1'/g" package/*/luci-app-sfe/root/etc/config/sfe
#下载DIY包
git clone --depth 1 https://github.com/jsda/opdiy.git ../opdiy && mv -f ../opdiy/diy package && echo "DIY包添加成功" || echo "DIY包添加失败"
#自定义源
echo "src/gz opbuild https://github.com/jsda/opbuild/raw/packages/ar71xx" >> package/system/opkg/files/customfeeds.conf
