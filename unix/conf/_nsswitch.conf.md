# `/etc/nsswitch.conf`
- NSS (Name Service Switch) の設定ファイル
- 名前解決を行う優先順位を指定するために使用される

```
# Fedora33より前 / RHEL7 / RHEL8
hosts:      files dns myhostname

# Fedora33以降
hosts:      files myhostname resolve [!UNAVAIL=return] dns
```

1. `files` (デフォルトで`/etc/hosts`) の定義を元に名前解決を試みる
2. 1に失敗した場合、`myhostname` (自身のホスト名やFQDN) の名前解決を試みる
3. 2に失敗した場合、`resolve` (`rystemd-resolved') による名前解決を試みる
4. `systemd-resolved`が動作していない場合、`dns` (`/etc/resolv.conf`) による名前解決を試みる
