## オリジン間リソース共有 (CORS)
- 異なるオリジンにあるリソースへのアクセス権を与える仕組み
  - セキュリティ上制限されているオリジン間のHTTPリクエストに許可を与える
  - Railsでは[rack-cors](https://github.com/cyu/rack-cors)を使用して、アクセスを許可するドメインの設定を行う

```
オリジン間リクエスト(例):
ドメイン = domain-hoge
オリジン = https://domain-hoge.com

https://domain-hoge.com で提供されているJavaScript コードが、
Ajaxでhttps://domain-fuga.com/data.json へリクエストを行う
```

- 指定されたオリジンからのリクエストを行う際、レスポンスが共有できるかどうかは
Access-Control-Allow-Origin レスポンスヘッダで示される
  - 参照: [Access-Control-Allow-Origin](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Access-Control-Allow-Origin)

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Origin: <origin>
Access-Control-Allow-Origin: null
```

## 引用
- [オリジン間リソース共有 (CORS)](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS)
