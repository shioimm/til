# `nc(1)`
- 任意のTCP / UDPのクライアント・サーバープロセスを起動する
- デフォルトではTCPのクライアントプロセスとして動作する

```
$ nc <option> IPアドレス ポート番号
```

- -u - UDPで通信する
- -l - サーバープロセスとして起動する
- -n - IPアドレスをDNSで名前解決しない
- -v - コマンドを詳細に表示する
- -w - タイムアウトまでの時間
- -z - ポート番号 (明示的)

## 参照
- Linuxで動かしながら学ぶTCP/IPネットワーク入門 5