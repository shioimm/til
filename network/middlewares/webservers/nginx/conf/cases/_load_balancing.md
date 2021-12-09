# 負荷分散
```
# 重み付け
upstream app {
  server aaa.aaa.a.aa:80 weight=3;
  server bbb.bbb.b.bb:80 weight=2;
  server ccc.ccc.c.cc:80;
}
```

```
#upstreamのアプリケーションサーバーのうち一台をバックアップにする

upstream app {
  server aaa.aaa.a.aa:80;        # 稼働系
  server ccc.ccc.c.cc:80 backup; # 待機系
}
```

```
# upstreamのアプリケーションサーバーのうち接続数が最も少ないものにアクセスする

upstream app {
  least_conn;
  server aaa.aaa.a.aa:80;
  server ccc.ccc.c.cc:80;
}
```

```
# 同じクライアントIPからのアクセスを同じupstreamに接続する

upstream app {
  ip_hash;
  server aaa.aaa.a.aa:80;
  server ccc.ccc.c.cc:80;
}
```

## 参照
- ngina実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
