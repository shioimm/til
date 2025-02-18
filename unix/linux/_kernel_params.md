# カーネルパラメータ
#### `net.core.somaxconn`
- listen中のソケットに対する接続要求の受け入れ可能キュー数 (backlog) の設定
  - デフォルト4096

```
$ sysctl net.core.somaxconn
> net.core.somaxconn = 4096

# 一時的に書き換える
$ sudo sysctl -w net.core.somaxconn=8192

# 恒久的に書き換える
$ vim /etc/sysctl.conf
# ---
net.core.somaxconn=8192
# ---
$ sudo sysctl -p
```

#### `net.ipv4.ip_local_port_range`
- クライアントホストが使用するエフェメラルポートの範囲の設定

```
$ sysctl net.ipv4.ip_local_port_range
> net.ipv4.ip_local_port_range = 32768 60999

# 一時的に書き換える
$ sudo sysctl -w net.ipv4.ip_local_port_range="1024 65535"

# 恒久的に書き換える
$ vim /etc/sysctl.conf
# ---
net.ipv4.ip_local_port_range=1024 65535
# ---
$ sudo sysctl -p
```
