# 安全なWebアプリケーションの作り方(脆弱性が生まれる原理と対策の実践) まとめ
- 徳丸浩 著

## 03 CORS
- 異なるオリジンのリソースへのアクセス権を与える仕組み

### シンプルなアクセス
- レスポンスに次のヘッダを追加する
  - `Access-Control-Allow-Origin` -> 指定したドメインに対してXMLHttpRequestなどのアクセスを許可する

#### シンプルなアクセスの条件
- GET / HEAD / POSTメソッドのいずれか
- Acceptヘッダ / Accept-Languageヘッダ / Content-Languageヘッダ / Content-Typeヘッダのみ
- Content-Typeは'application/x-www-form-urlencoded' / 'multipart/form-data' / 'text/plain'のいずれか

### シンプルなアクセス以外
- レスポンスに次のヘッダを追加する
  - `Access-Control-Allow-Origin` -> 指定したドメインに対してXMLHttpRequestなどのアクセスを許可する
  - `Access-Control-Allow-Method` -> 指定したメソッドに対してXMLHttpRequestなどのアクセスを許可する
  - `Access-Control-Allow-Headers` -> 指定したヘッダに対してXMLHttpRequestなどのアクセスを許可する
  - `Access-Control-Max-Age` -> `Access-Control-Allow-Methods` / `Access-Control-Allow-Headers`ヘッダに
  含まれる情報をキャッシュする時間の長さを指定する

### 認証情報を含むリクエスト
- XMLHttpRequestオブジェクトの`withCredentials`プロパティをtrueにする
- レスポンスに次のヘッダを追加する
  - `Access-Control-Allow-Credentials: true` -> レスポンスをクライアントスクリプトに公開することをブラウザに指示
