# upstreamのアプリケーションサーバーで実行されたリダイレクトのLocationを書き換える
```
upstream app1 {
  server ***.***.*.**:80;
}

server {
  server_name app2.com;
  location /aaa/ {
    proxy_pass     http://app1/bbb/;
    proxy_redirect http://app1/bbb http://app2.com/aaa/; # 変換対象の文字列 変換後の文字列
  }

  location /ccc/ {
    rewrite        ^/ccc/1 /ccc/2;
    proxy_pass     http://app1/ddd/;
    proxy_redirect http://app1/ddd/2 http://app2.com/ccc/1;

    proxy_cookie_path   /ccc/ /aaa/; # 変換対象の文字列 変換後の文字列
    proxy_cookie_domain app1 $server_name;
  }
}
```
## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
