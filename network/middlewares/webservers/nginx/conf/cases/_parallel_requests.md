# クライアントIPの同時接続数を制限
```
http {
  limit_conn_zone $binary_remote_addr zone=addr:10m; # 接続数を数えるキー名・ゾーン名・ゾーンサイズ

  server {
    limit_conn addr 10; # ゾーン名・最大接続数
  }
}
```

### クライアントIPのリクエスト数のスループットを制限
```
http {
  limit_conn_zone $binary_remote_addr zone=addr:10m; # 接続数を数えるキー名・ゾーン名・ゾーンサイズ

  server {
    limit_req zone=addr burst=10; # ゾーン名・10アクセスまでは毎秒1リクエストとしてスループットさせる
  }
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
