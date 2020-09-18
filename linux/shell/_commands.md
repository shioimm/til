# よく使うコマンド
### コマンドを一定間隔ごとに繰り返し実行し結果を表示する
```
$ watch xxxx
```

### ファイルを探す
```
$ find パス -type ファイルタイプ -name ファイル名
```

### サービスの操作
- ディストリビューションによってサービス名が異なる場合がある
  - Ex: Apache(Redhat: httpd / Debian: apache2)
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

## ネットワーク
### 疎通確認
```
$ ping ドメイン名 or IPアドレス
```

### 経路確認
```
$ traceroute ドメイン名 or IPアドレス
```

### DNS要求を行う
```
$ nslookup ドメイン名
$ nslookup IPアドレス

$ host ホスト名
$ host ドメイン名
$ hots IPアドレス

$ dig ホスト名
$ dig ドメイン名
$ dig IPアドレス
```

### Whois情報を調べる
```
$ whois ドメイン名
$ whois IPアドレス
```

### 任意のドメインのサーバーを調べる
```
$ dig ドメイン名 a +short
$ whois IPアドレス
```

### ネームサーバーを調べる
```
$ dig ドメイン名 ns +short
```

## プロセス
### 負荷の大きいプロセスの確認
```
$ top
```

### メモリの使用率を確認
```
$ free
```

### ディスクの使用率を確認
```
$ df -h # ディスク全体
$ du -h # ディレクトリ・ファイル単位
```

### プロセスをバックグラウンドで起動
```
$ xxxx & # コマンド末尾に&を追加
```

### プロセスをフォアグラウンドで起動
```
$ fg プロセスID
```

## その他
### スワップ領域の確保
```
$ mkswap /swapfile # スワップ領域の確保
$ swapon /swapfile # 確保した領域を使用
```

```
# /etc/fstab
# 次回ブート時にスワップ領域を有効化させる

/swapfile swap swap defaults 0 0
```

### マニュアル
```
$ man 1 xxx # コマンド
$ man 2 xxx # システムコール
$ man 3 xxx # ライブラリ関数
$ man 4 xxx # スペシャルファイル
$ man 5 xxx # ファイルフォーマット
$ man 6 xxx # ゲーム
$ man 7 xxx # その他
$ man 8 xxx # 管理用コマンド
```

```
NAME         コマンド名・概要
SYNOPSIS     書式
DESCRIPTION  詳細
OPTION       オプション
RETURN VALUE 返り値
ERROR        エラー
FILES        関連ファイル
SEE ALSO     関連コマンド
```

### データをバイトストリーム上に表示
```
$ od -c xxx.txt
```
