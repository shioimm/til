# ヘッダを付与する
```
# 接続先がクライアントである場合

server {
  add_header XXX $xxx;
  add_header YYY $yyy;
}
```

```
# 接続先がupstreamのアプリケーションサーバーである場合
# 追加・変更・削除されるもの以外はクライアントから受信したヘッダがそのまま送信される

server {
  proxy_set_header XXX $xxx;
  proxy_set_header YYY $yyy;
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
