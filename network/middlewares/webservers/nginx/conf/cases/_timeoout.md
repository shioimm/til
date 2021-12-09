# タイムアウト
```
# ダウン条件の判定

server {
  location /aaa/ {
    proxy_pass            http://app/bbb/;
    proxy_connect_timeout 60s; # 接続時タイムアウト
    proxy_read_timeout    60s; # 受信時タイムアウト
    proxy_send_timeout    60s; # 送信時タイムアウト
  }
}

upstream app {
  server ***.***.*.x** max_fails=1 fail_timeout=10s;
  # max_fails    - 失敗したアクセスの回数
  # fail_timeout - 失敗判定する時間 / 失敗判定後アクセスを控える時間
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
