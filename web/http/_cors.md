## オリジン間リソース共有 (CORS)
- 参照: [オリジン間リソース共有 (CORS)](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS)
- 異なるオリジンにあるリソースへのアクセス権を与える仕組み
  - セキュリティ上制限されているオリジン間のHTTPリクエストに許可を与える
  - Railsでは[rack-cors](https://github.com/cyu/rack-cors)を使用して、アクセスを許可するドメインの設定を行う
