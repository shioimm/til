# tc(8)
- 送信パケットの帯域制御を行う(Traffic Control)
- iproute2パッケージに含まれる
- qdiscを利用して送信パケット送信順序の変更、遅延、削除等操作を行う

### qdisc(Queueing Discipline)
- キューイング規則
- 送信パケットはqdisc -> カーネル -> ドライバへ受け渡される

## 参照
- [よくわかるLinux帯域制限](https://labs.gree.jp/blog/2014/10/11266/)
- [Linuxでトラフィック制御をしたい（tcコマンド）](https://cha-shu00.hatenablog.com/entry/2020/02/10/131836)
