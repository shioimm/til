# 設定
```
# /etc/nginx/nginx.conf

coreモジュールの設定(mainコンテキスト)

events {
  eventモジュールの設定
}

http {
  httpモジュールの設定
  server {
    サーバ毎の設定

    location PATH {
      URI毎の設定
    }
    location PATH {
      URI毎の設定
    }
   ...
  }
  ...
}

mail {
  mailモジュールの設定
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
