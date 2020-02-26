# Actions-OpenWrt

![Build OpenWrtx64](https://github.com/jsda/opbuild/workflows/Build%20OpenWrtx64/badge.svg)

Build OpenWrt using GitHub Actions

[Read the details in my blog (in Chinese) | 中文教程](https://p3terx.com/archives/build-openwrt-with-github-actions.html)

[GitHub Actions Group](https://t.me/GitHub_Actions) | [GitHub Actions Channel](https://t.me/GitHub_Actions_Channel)

## 安装软件包

You can use the following command to get architecture.
```
opkg print-architecture | awk '{print $2}'
```

Then, check your architecture in all branches and add the following line to `/etc/opkg.conf`.
```
src/gz opbuild https://github.com/jsda/opbuild/raw/packages/{architecture}
```
Then install what you want.
```
opkg update

opkg install adbyby
opkg install luci-app-adbyby-plus
opkg install kcptun-client
opkg install pdnsd-alt
opkg install simple-obfs
opkg install trojan
opkg install v2ray
opkg install v2ray-plugin
opkg install luci-app-ssr-plus
opkg install chinadns-ng
opkg install dns2socks
opkg install tcping
opkg install luci-app-passwall
opkg install luci-app-kcptun
opkg install vlmcsd
opkg install luci-app-vlmcsd
```
For more detail please check the source code.

## Acknowledgments

- [Microsoft](https://www.microsoft.com)
- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub](https://github.com)
- [GitHub Actions](https://github.com/features/actions)
- [tmate](https://github.com/tmate-io/tmate)
- [mxschmitt/action-tmate](https://github.com/mxschmitt/action-tmate)
- [csexton/debugger-action](https://github.com/csexton/debugger-action)
- [Cisco](https://www.cisco.com/)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)

## License

[MIT](https://github.com/P3TERX/Actions-OpenWrt/blob/master/LICENSE) © P3TERX
