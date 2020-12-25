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
