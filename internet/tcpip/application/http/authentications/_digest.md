# Digest認証
- 参照: Real World HTTP 第2版

## TL;DR
- ハッシュ関数を利用した認証
- 現在はあまり使われておらず、フォームを使ったログイン + Cookieを使ったセッション管理の組み合わせによる認証が一般的

## ヘッダ
### レスポンスヘッダ
```
WWW-Authenticate: Digest realm=<realm>,         # 保護エリア
                         nonce=<nonce>,         # サーバーが生成するランダムなデータ
                         algorithm=<algorithm>, # ハッシュアルゴリズム
                         qop=<qop>              # 保護データ
```

### リクエストヘッダ
```
Authorization: Digest username=<username>,
                      realm=<realm>,
                      nonce=<nonce>,
                      uri=<uri>,
                      algorithm=<algorithm>,
                      qop=<qop>,
                      nc=<nc>,
                      cnonce=<cnonce>,
                      response=<response>
```
