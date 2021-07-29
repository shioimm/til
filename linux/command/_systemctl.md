# サービスの操作
- ディストリビューションによってサービス名が異なる場合がある
  - Ex: Apache(Redhat: `httpd` / Debian: `apache2`)
```
# 起動・終了・再起動
$ sudo systemctl start xxxx   # サービスxxxxを起動する
$ sudo systemctl stop xxxx    # サービスxxxxを起動する
$ sudo systemctl restart xxxx # サービスxxxxを再起動する

# 自動起動
$ sudo systemctl enable xxxx  # サービスxxxxを自動起動する
$ sudo systemctl disable xxxx # サービスxxxxの自動起動を止める
$ sudo systemctl is-enabled    # サービスxxxxの自動起動の確認

# 状態
$ sudo systemctl status xxxx  # サービスxxxxの状態を確認する
```
