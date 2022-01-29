# Keep-Aliveの時間を設定する
```
# 接続先がクライアントである場合

server {
  keepalive_timeout 60;
}
```

```
# 接続先がupstreamのアプリケーションサーバーである場合

upstream app {
  server    xxx.xxx.x.xx:80;
  keepalive 32; # Keep-Aliveで保持する待機中のコネクション数(workerごと)
}

server {
  location / {
    proxy_http_version 1.1:
    proxy_set_header   Connection "";
    proxy_pass         http://app;
  }
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
