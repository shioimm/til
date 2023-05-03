# ssh
#### ポートフォワーディング
- SSHサーバを経由して目的サーバにアクセスする
- ローカルで使用するポート番号に対する通信が目的サーバの待ち受けポートへ到達するようになる

```
$ ssh \
-L <ローカルで使用するポート番号>:<目的サーバのアドレス>:<目的サーバのポート番号> \
<SSHサーバのユーザー名>@<SSHサーバのアドレス>
```

## 参照
- [楽しいトンネルの掘り方(オプション: -L, -R, -f, -N -g)](https://www.kmc.gr.jp/advent-calendar/ssh/2013/12/09/tunnel2.html)
- [A Visual Guide to SSH Tunnels: Local and Remote Port Forwarding](https://iximiuz.com/en/posts/ssh-tunnels/)
