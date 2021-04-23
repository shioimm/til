# SSH
- 参照: [ssh 【 Secure SHell 】 セキュアシェル](http://e-words.jp/w/ssh.html)

## TL;DR
- ネットワークを介しリモートホストに遠隔ログイン・操作するためのソフトウェア
- 公開鍵暗号と秘密鍵暗号を組み合わせることで通信経路が暗号化される
- sshd - 外部からのsshによる接続を受け付けるデーモンプロセス
- scp - ローカルホスト - リモートホスト間でファイルをコピーするコマンド・プロトコル

## Get Started
(Debian)
- [Debian GNU/Linux 4.0(etch)にOpenSSHをインストール](http://www.bnote.net/kuro_box/ssh_inst.shtml)

```
# sshをインストール
$ sudo aptitude update
$ sudo aptitude install ss
# OpenSSHクライアントとOpenSSHサーバーがインストールされる

# ssh_configのバックアップを取っておく(`ssh_config.org`)
$ sudo cp /etc/ssh/sshd_config  /etc/ssh/sshd_config.org

# 設定を変更 PermitRootLogin -> no
$ sudo vi /etc/ssh/sshd_config

# sshを再起動
$ sudo /etc/init.d/ssh restart
```

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
