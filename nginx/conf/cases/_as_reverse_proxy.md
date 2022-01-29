# nginxをリバースプロキシとして使う
- `server` - Webサーバー
- `upstream` - アプリケーションサーバー

```
# proxy_passにupstreamの名前を指名
http {
  upstream app {
    server ***.***.*.**:80;
    server yyy.yyy.y.yy:80;
    server zzz.zzz.z.zz:80;
  }

  server {
    listen 80:
    location / {
      proxy_pass http://app;
    }
  }
}
```

```
# 転送先が一つの場合、直接IPアドレスとポート番号を指定できる

http {
  server {
    listen 80:
    location / {
      proxy_pass http://***.***.*.**:80;
    }
  }
}
```

```
# proxy_passの引数のURLにパス名を含めない場合
#   クライアントから受信したパスがupstreamのアプリケーションサーバーに送信される
# proxy_passの引数のURLにパス名を含める場合
#   クライアントから受信したパスから`location`でマッチした部分を除き、
#   指定したパス名を足したパスがupstreamのアプリケーションサーバーに送信される

http {
  server {
    listen 80:
    location /yyy {
      proxy_pass http://***.***.*.**:80/zzz/:
      # GET /yyy      -> GET /zzz/
      # GET /yyy1/aaa -> GET /zzz/1/aaa
    }
  }
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
