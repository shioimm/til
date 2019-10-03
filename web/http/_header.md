### Feature-Policy
- 参照: [https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy)
- 参照: [機能ポリシーの使用](https://developer.mozilla.org/ja/docs/Web/HTTP/Feature_Policy/Using_Feature_Policy)
- 参照: [Rails 6.1 adds HTTP Feature Policy](https://blog.saeloun.com/2019/10/01/rails-6-1-adds-http-feature-policy.html)
- レスポンスヘッダに含まれる(iframeの`allow`属性で設定することもできる)
- Webサイト全体でどの機能が使用できるかを制御する役割を持っている
- Railsではconfig/initializers/feature_policy.rbに設定を置く(6.1以降)
  - controllerで機能ごとに設定を上書きすることもできる

### Vary
- from https://triple-underscore.github.io/RFC7231-ja.html#section-7.1.4
- レスポンスヘッダに含まれる
- Varyはキャッシュキーを拡張する役割を持っている
```
- キャッシュキーとは
  - from https://cloud.google.com/cdn/docs/caching?hl=ja#cache-keys
  - 保存されたキャッシュエントリを識別するためのインデックス
  - リクエストが持っているキーとの比較によって、合致した場合に対応したオブジェクトが返される
```

- 例
```
Vary: accept-encoding, accept-language
```
- ↑の場合レスポンスは、今後のリクエストにおいて、そのリクエストの [ Accept-Encoding, Accept-Language ] をキャッシュキーとして使用することを伝える
  - リクエストの［ Accept-Encoding, Accept-Language ] が元のリクエストと同じ値だった場合のみ、レスポンスを返す
  - レスポンスの [ Accept-Encoding, Accept-Language ] いずれかのヘッダ内にパラメータが追加される場合，後続のリクエストに対して意図と異なるオブジェクトが送信される可能性がある
