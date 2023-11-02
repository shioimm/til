# RedisToGo -> Heroku Redisへの移行作業メモ
## 移行理由
- Sidekiq5->6系へのupdateの際、Herokuアドオンで使用しているRedisToGoの最新バージョンが古かったため

## 事前準備
- 他にどういうアドオンがあるのか調査(現在はRedisToGoのmicro)
  - バージョン(4.0以上)
  - コネクション数
  - メモリ
  - マイグレーションが楽にできそうか
  - ドキュメントが揃っているか
- -> Heroku Redisに決定

## Todo:
1. Heroku Redisをアドオンに追加
2. アプリケーション側の設定と新しい環境変数を追加するPRをマージ
3. メンテナンスモードに切り替え
    - ワーカーも止める
4. 本番投入
    - 事前にprebootをoff
5. メンテナンスモードを解除
6. RedisToGoのアドオン解除

## 作業ログ
1. Heroku RedisをGUIでアドオンに追加
    - 本番 -> Heroku Redis premium-0
    - ステージング -> Heroku Redis hobby-dev
2. heroku configに新しい環境変数`REDIS_URL`が追加されたことを確認
3. 環境変数`REDISTOGO_URL`が記述されている箇所を`REDIS_URL`に変更するPRを立てる
    - 対象箇所
      - app.json
      - config/cable.yml
      - config/environments/production.rb
      - config/environments/staging.rb
      - config/initializers/redis.rb
      - config/initializers/sidekiq.rb
      - config/initializers/websocket_rails.rb
4. app.jsonの`addons`に追加されていた`redistogo`を`heroku-redis`に変更
5. review appsで動作確認し、問題なかったためマスターにマージ
6. ステージングにてRedisToGoからHerokuRedisへのマイグレーションを行おうとするが、
CLIでアドオンを追加し、その際に古いインスタンスをフォークするしか方法がないことがわかる
7. CLIからステージングに`hobby-dev`を追加
```
$ heroku addons:create heroku-redis:premium-0 --fork redis://h:<password>@<hostname>:<port> -a sushi
```
8. 環境変数`HEROKU_REDIS_URL_BROWN`が追加される
9. フォーク完了後、`HEROKU_REDIS_URL_BROWN`を`REDIS_URL`に付け替えるため次のコマンドを実行
```
$ heroku redis:promote 新しいRedisのインスタンス名 -a sushi
```
10. `REDIS_URL`が`HEROKU_REDIS_URL_BROWN`と同じURLに書き換わり、
元々`REDIS_URL`に入っていたURLが新しい環境変数`HEROKU_REDIS_URL_ COBALT`として追加される
11. フォークした結果、過去の全てのジョブが移行されるわけではないことがわかる
12. 期待していた結果と異なるため、本番環境においてはフォークせずにそのまま新しいアドオンを追加することにする
    - 待機中のジョブがないことを確認
13. Herokuをメンテナンスモードに入れる
14. prebootをoffにする
```
$ heroku features:disable -a myapp preboot
```
15. 本番デプロイ
16. prebootをonにする
```
$ heroku features:enable -a myapp preboot
```
17. メンテナンスモードを解除
18. 動作確認
19. RedisToGoアドオンを解除
