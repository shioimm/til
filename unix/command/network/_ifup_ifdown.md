# `ifup` / `ifdown`
- 特定のNICの再起動に利用されるコマンド
  - `$ service network restart`で利用される
  - ただし`$ service network restart`はすべてのNICが再起動の対象になる

#### `ifup`
- `/etc/sysconfig/network-scripts/ifup`を実行し、指定したNICを有効にする
- 静的 / 動的なIPアドレスの設定を含めNICの初期化を行う

#### `ifdown`
- `/etc/sysconfig/network-scripts/ifdown`スクリプトを実行し、指定したNICを無効にする
- IPアドレスの開放及びdhclient (DHCPクライアント機能) の停止を行う
