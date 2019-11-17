## オリジン間リソース共有 (CORS)
- 引用: [オリジン間リソース共有 (CORS)](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS)
```
オリジン間リクエスト(例):
https://domain-a.com で提供されている
ウェブアプリケーションのフロントエンドJavaScript コードがXMLHttpRequestを使用して
https://domain-b.com/data.json へリクエストを行う:
```
- 異なるオリジンにあるリソースへのアクセス権を与える仕組み
  - セキュリティ上制限されているオリジン間のHTTPリクエストに許可を与える
  - Railsでは[rack-cors](https://github.com/cyu/rack-cors)を使用して、アクセスを許可するドメインの設定を行う
