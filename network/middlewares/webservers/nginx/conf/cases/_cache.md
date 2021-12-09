# キャッシュ
```
http {
  proxy_cache_path /var/cache/nginx/rproxy # キャッシュディレクトリ
                   levels=1:2              # キャッシュディレクトリ構造(0-9:00-99)
                   keys_zone=zone:10m      # ゾーン(workerの共有メモリ領域)名:サイズ
                   inactive=1d;            # キャッシュが破棄されるまでの時間

  upstream app {
    server ***.***.*.**:80;
  }

  server {
    location / {
      proxy_cache zone # ゾーン名
      proxy_pass  http://app;

      proxy_cache_bypass $http_authorization $http_cookie; # キャッシュからレスポンスを返さない
      proxy_no_cache     $http_authorization $http_cookie; # コンテンツをキャッシュしない
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
