# systemd
#### systemd-resolved
- スタブリゾルバ (DNSクライアント) としての機能をローカルアプリケーションに提供するsystemdコンポーネント
- D-Bus API、NSS、Local DNS Stub Listener (127.0.0.53:53) に対応
- 設定は`/etc/systemd/resolved.conf`に記述する
