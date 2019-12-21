# cURL
### ログインしてPOSTでデータを送信したい(Rails)
```shell
: ログインする
curl -H 'Content-Type: application/json' \
     -X POST https://example.com/sign_in \ : メソッドとログイン先の指定
     -d '{"user":{"username":"username","password":"password"}}' : ログインデータの送信
     -c cookie : Cookieの書き出し
     -b cookie : Cookieを読み込み
     -u basic-username:basic-password : Basic認証のユーザー名とパスワード

: csrf-tokenを調べる
curl https://example.com/ \ : 適当なページにアクセス
     -c cookie \
     -b cookie \
     -u basic-username:basic-password | grep csrf : metaタグをgrep

: データをPOSTする
curl -X POST https://example.com/api/v1/hoges/1/fugas \
     -H 'Content-Type: application/json' \
     -d '{"fugas":{"like_master_id": "1"}}' \
     -c cookie \
     -b cookie \
     -H 'X-CSRF-TOKEN: 調べたcsrf-token'
     -u basic-username:basic-password
```
