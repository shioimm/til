### メモリの使用率を確認
```
$ free
```

### ディスクの使用率を確認
```
$ df -h # ディスク全体
$ du -h # ディレクトリ・ファイル単位
```

### コマンドを一定間隔ごとに繰り返し実行し結果を表示する
```
$ watch xxxx
```

### ファイルを探す
```
$ find パス -type ファイルタイプ -name ファイル名
```

### 二つのファイルの差分を表示
```
$ diff xxx yyy
```
- ファイル`xxx`とファイル`yyy`の差分を表示

### パーミッションの変更
```
$ chmod u+x xxxx
```

#### 対象ユーザー
- `u` - 所有ユーザー
- `g` - 所有グループ
- `o` - その他のユーザー

#### 権限の変更
- `+r` - 読み込み権限を許可する
- `+w` - 書き込み権限を許可する
- `+x` - 実行権限を許可する
- `-r` - 読み込みを不許可にする
- `-w` - 書き込みを不許可にする
- `-x` - 実行を不許可にする

### ユーザーの追加 / 削除
```
$ sudo adduser

# 新しいユーザーのnameを入力
# 新しいユーザーのUIDを入力(デフォルト設定あり)
# 新しいユーザーのgroupを入力(デフォルト設定あり)
# 新しいユーザーのAdditional groupsを入力(空値可)
# 新しいユーザーのHome directoryを入力(デフォルト設定あり)↲
# 新しいユーザーのShellを入力(デフォルト設定あり)↲
# 新しいユーザーのExpiry dateを入力(空値可)
# 新しいユーザーのpasswordを入力

$ userdel -r 削除したいユーザーのname
```

### サービスの操作
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
