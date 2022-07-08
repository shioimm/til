# Heroku
#### Dyno
- Amazon EC2インスタンス上で動作する軽量Linuxコンテナ
- Dyno内の常駐プロセスが以上終了した場合は自動的にリスタートが走る

#### Heroku Router
- いずれかのWeb dynoにHTTPリクエストを転送するルーター
- リクエストはロードバランサによって受信された後Heroku Routerに転送される
- Heroku Routerはレスポンスまでに30秒以上かかるリクエストをタイムアウトさせる

#### One-off dyno
- `$ heroku run`を実行するためのdyno

## 参照
- [構築・運用の必須知識！ Herokuアプリケーションの実行プラットフォーム「Dyno」を徹底的に理解する](https://codezine.jp/article/detail/8344)
- [HTTP ルーティング](https://devcenter.heroku.com/ja/articles/http-routing)
- [One-off dyno](https://devcenter.heroku.com/ja/articles/one-off-dynos)
