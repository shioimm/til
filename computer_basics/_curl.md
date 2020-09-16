# cURL
### ログインしてPOSTでデータを送信したい(Rails)
```shell
: ログインする
curl -X POST https://example.com/sign_in \ : メソッドとログイン先の指定
     -H 'Content-Type: application/json' \ : Content-Typeの指定
     -d '{"user":{"username":"username","password":"password"}}' \ : パラメータの送信
     -c cookie \ : Cookieの書き出し
     -b cookie \ : Cookieを読み込み
     -u basic-username:basic-password : Basic認証のユーザー名とパスワード

: csrf-tokenを取得する
curl https://example.com/ \ : 任意のURLにアクセス
     -c cookie \
     -b cookie \
     -u basic-username:basic-password | grep csrf: metaタグをgrep

: データをPOSTする
curl -X POST https://example.com/api/v1/hoges/ \
     -H 'Content-Type: application/json' \
     -d '{"fugas":{"like_master_id": "1"}}' \
     -c cookie \
     -b cookie \
     -H 'X-CSRF-TOKEN: 取得したcsrf-token' \
     -u basic-username:basic-password

: データをDELETEする
curl -X DELETE https://example.com/api/v1/hoges/削除するレコードのid \
     -H 'Content-Type: application/json' \
     -c cookie \
     -b cookie \
     -H 'X-CSRF-TOKEN: 取得したcsrf-token' \
     -u basic-username:basic-password
```
