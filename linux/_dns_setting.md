# DNS設定
#### `/etc/resolv.conf`
- 名前解決の設定を行うファイル
- systemd-resolved以前に使用されていた

```
nameserver     <利用したいDNSフルリゾルバのIPアドレス: 1>
nameserver     <利用したいDNSフルリゾルバのIPアドレス: 2>
domain         <当該ホストが所属するドメイン>
```

#### systemd-resolved
- スタブリゾルバ (DNSクライアント) としての機能をローカルアプリケーションに提供するsystemdコンポーネント
- D-Bus API、NSS、Local DNS Stub Listener (127.0.0.53:53) に対応
- 設定は`/etc/systemd/resolved.conf`に記述する
