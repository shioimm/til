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

#### `net.ipv4.tcp_fastopen`
- TCP Fast Openを有効にするかどうか
  - 0 = TFO を無効化 (デフォルト)
  - 1 = クライアントとしてTFOを有効化 (サーバ側のサポートが必要)
  - 2 = サーバとしてTFO を有効化 (クライアント側のサポートが必要)
  - 3 = クライアント・サーバとしてTFO を有効化

#### `net.ipv4.tcp_fin_timeout`
- FIN送信後、カーネルがTIME-WAIT状態を維持する時間 (秒)

#### `net.ipv4.ip_local_port_range`
- ユーザ空間プロセスが動的に割り当てられるローカルポートの範囲

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

#### `net.ipv4.tcp_max_tw_buckets`
- TIME-WAIT 状態のソケットの最大数

#### `net.ipv4.tcp_max_syn_backlog`
- サーバとして受け付けるSYNキューのサイズ

#### `net.ipv4.tcp_syn_retries`
- TCPハンドシェイクの最初のSYN送信後、SYN-ACKを受信できない場合にSYNを再送する最大回数

#### `net.ipv4.tcp_tw_reuse`
- TCPコネクション確立時に使用していたローカルポートをTIME-WAIT状態のソケットを再利用するかどうか
  - 1 = TIME-WAIT状態のソケットを再利用する
  - 2 = TIME-WAITからCLOSEDになったソケットのみ再利用する
