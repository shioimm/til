# Cache-Status
- キャッシング情報を表現するレスポンスヘッダ
  - そのレスポンスはキャッシュから送信されたのか、サーバから送信されたのか
  - キャッシュから返された場合、どのキャッシュか、あとどれくらい有効か
  - キャッシュから返されたのではない場合、それはなぜか

```
Cache-Status: CacheName; param; param=value; param..., CacheName2; param; param...
```

- レスポンス順 (オリジンサーバーに近い順) に並んだキャッシュのリスト

```
Cache-Status:
    Nginx; hit,
    Cloudflare; fwd=stale; fwd-status=304; collapsed; ttl=300,
    BrowserCache; fwd=vary-miss; fwd-status=200; stored
```

クライアントがリクエストを送信した後:

1. Varyヘッダに含まれるヘッダがブラウザのキャッシュレスポンスにヒットせず (`fwd=vary-miss`) 、
   Cloudflareにリクエストを送信した
    - Varyヘッダに含まれるヘッダが一致しなかったため
2. Cloudflareがリクエストを受信し、Cloudflareは一致するレスポンスをキャッシュしていたが (`Nginx; hit`)
   レスポンスが古いため (`fwd=stale`) Nginxにレスポンスを再検証するようリクエストを送信した
3. Nginxは304 (変更なし) レスポンスをCloudflareに送信した (`fwd-status=304`)

## 参照
- [The Cache-Status HTTP Response Header Field](https://datatracker.ietf.org/doc/rfc9211/)
- [モダンWebにおけるキャッシングのための新HTTP標準](https://postd.cc/status-targeted-caching-headers/)
