# SSH
## 鍵認証
- 参照: [ssh接続を鍵認証で行う](http://www.tooyama.org/ssh-key.html)

### SSHクライアントにキーペアを作成
```
$ cd ~/.ssh; ssh-keygen
# パスワードを入力する
# パスワード入力しない場合、パスワードなしのキーペアを作成する

# オプション-f - 鍵の名前の指定
$ ssh-keygen -f xxx_rsa

# オプション-t - 鍵の種類の指定(rsa、dsa、ecdsa etc)
$ ssh-keygen -t rsa

# オプション-b - 鍵の暗号化強度
$ ssh-keygen -b 2048

$ cd ~/.ssh; ssh-keygen -f xxx_rsa -t rsa -b 2048
```
- 公開鍵(`.pub`がついたファイル)と秘密鍵(`.pub`がついていないファイル)が作成される

### SSHクライアントにキーペアを登録
```
$ ssh-add -K ~/.ssh/xxx_rsa
```

### SSHサーバーに公開鍵を登録
```
$ ssh-copy-id -i ~/.ssh/xxx_rsa.pub USER@HOSTNAME
# USER - 接続先アカウント名
# HOSTNAME - 接続先ホスト名
```
- あるいは接続先のGUIから公開鍵を登録する
