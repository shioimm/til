# systemd
#### systemd-resolved
- スタブリゾルバ (DNSクライアント) としての機能をローカルアプリケーションに提供するsystemdコンポーネント
- D-Bus API、NSS、Local DNS Stub Listener (127.0.0.53:53) に対応
- 設定は`/etc/systemd/resolved.conf`に記述する

#### socket activation (ソケットアクティベーション)

```
# /etc/systemd/system/***.socket
[Socket]
ListenStream=8080
Accept=no

# Accept=yes
#   初回の接続要求時に1つのプロセスが起動され、その後はそのプロセスが引き続き接続を処理 (Webサーバ、DBサーバなど)
#   systemdはソケットをオープンしたまま維持しつつ、サービスの起動だけをトリガー
# Accept=no
#  クライアントからの接続要求ごとに新しいプロセスが起動 (echo、ftpなど)
```
