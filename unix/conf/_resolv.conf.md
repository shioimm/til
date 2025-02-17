# `/etc/resolv.conf`
- 名前解決の設定を行うファイル
- Fedora33 (systemd-resolvedの登場) より前に使用されていた

```
nameserver     <利用したいDNSフルリゾルバのIPアドレス: 1>
nameserver     <利用したいDNSフルリゾルバのIPアドレス: 2>
domain         <当該ホストが所属するドメイン>
```
