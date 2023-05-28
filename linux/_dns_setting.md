# DNS設定
#### `/etc/nsswitch.conf`
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

#### `/etc/resolv.conf`
- 名前解決の設定を行うファイル
- Fedora33 (systemd-resolvedの登場) より前に使用されていた

```
nameserver     <利用したいDNSフルリゾルバのIPアドレス: 1>
nameserver     <利用したいDNSフルリゾルバのIPアドレス: 2>
domain         <当該ホストが所属するドメイン>
```

#### systemd-resolved
- スタブリゾルバ (DNSクライアント) としての機能をローカルアプリケーションに提供するsystemdコンポーネント
- D-Bus API、NSS、Local DNS Stub Listener (127.0.0.53:53) に対応
- 設定は`/etc/systemd/resolved.conf`に記述する

## 参照
- [`/etc/nsswitch.conf`のhosts行を理解する](https://endy-tech.hatenablog.jp/entry/dns_nss)
