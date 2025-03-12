# Heroku
#### Dyno
- Amazon EC2インスタンス上で動作する軽量Linuxコンテナ
- Dyno内の常駐プロセスが以上終了した場合は自動的にリスタートが走る
- One-off dyno - `$ heroku run`を実行するためのdyno

#### Heroku Router
- いずれかのWeb dynoにHTTPリクエストを転送するルーター
- リクエストはロードバランサによって受信された後Heroku Routerに転送される
- Heroku Routerはレスポンスまでに30秒以上かかるリクエストをタイムアウトさせる

#### Heroku Buildpack
- 各開発言語やカスタム要素をサポートし、コンパイルとスラッグの作成を行うために利用される機能
  - スラッグ - 圧縮・パッケージ化されたアプリケーションとランタイムのコピー
    - Dyno Managerへの配信に最適化されている
- pushしたアプリケーションから分析したBuildpackもしくは明示的に指定したBuildpackが割り当てられる

## 参照
- [構築・運用の必須知識！ Herokuアプリケーションの実行プラットフォーム「Dyno」を徹底的に理解する](https://codezine.jp/article/detail/8344)
- [HTTP ルーティング](https://devcenter.heroku.com/ja/articles/http-routing)
- [One-off dyno](https://devcenter.heroku.com/ja/articles/one-off-dynos)
- [Heroku Buildpack](https://jp.heroku.com/elements/buildpacks)
