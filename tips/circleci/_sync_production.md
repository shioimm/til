# 20201210 本番環境のDBをステージング環境へ定期的に同期させる
## 動機
- 本番環境と同じデータを安全なステージング環境に用意することにより、
  動作確認やバグ修正を容易に行えるようにする

## 環境
- Heroku環境
- メディアの保存にS3を使用
  - S3内に本番用・ステージング用のディレクトリを持つ
- circleci-cliを用意しておく

## 設定
- CircleCI環境変数へ設定を追加
  - `HEROKU_API_KEY` - Herokuアカウントの`HEROKU_API_KEY`
    - `HEROKU_API_KEY`を設定することにより`heroku login`なしで`heroku`コマンドが打てる
  - `STAGING_APP_NAME` - Herokuステージング環境アプリケーション名
    - 動作確認のため環境変数で管理しておく
  - `AWS_ACCESS_KEY_ID` - AWS IAMのS3アクセス用パラメータ
  - `AWS_SECRET_ACCESS_KEY` - AWS IAMのS3アクセス用パラメータ
  - `AWS_DEFAULT_REGION` - AWS IAMのS3アクセス用パラメータ
- Herokuステージング環境のDBプランをアップグレード(standard-0)
  - [Upgrading the Version of a Heroku Postgres Database](https://devcenter.heroku.com/articles/upgrading-heroku-postgres-databases)

## `.circleci/config.yml`
### Orbs
```yml
orbs:
  # ...
  heroku: circleci/heroku@1.2.3
  aws-cli: circleci/aws-cli@1.3.1
```
- [circleci/heroku@1.2.3](https://circleci.com/developer/orbs/orb/circleci/heroku)
  - [> Commands > install](https://circleci.com/developer/orbs/orb/circleci/heroku#commands-install)
- [circleci/aws-cli@1.3.1](https://circleci.com/developer/orbs/orb/circleci/aws-cli)
  - [> Commands > setup](https://circleci.com/developer/orbs/orb/circleci/aws-cli#commands-setup)

### Jobs
#### DBの同期
```yml
jobs:
  # ...
  restore_database:
    executor: heroku/default
    steps:
      - checkout
      - heroku/install
      - run:
          command: |
            heroku pg:backups:restore `heroku pg:backups public-url -a 本番環境アプリケーション名` -a $STAGING_APP_NAME --confirm $STAGING_APP_NAME
            heroku run rake db:migrate -a $STAGING_APP_NAME
```
- `$ heroku pg:backups:restore`
  - 本番環境のDBをステージング環境へ同期
- `$ heroku run rake db:migrate`
  - ステージングに`db/migrate/*.rb`の変更が適用され、本番未デプロイの場合
    本番DBをstagingにリストアすると発生する`ActiveRecord::PendingMigrationError`を回避

#### S3の同期
```yml
jobs:
  # ...
  sync_s3:
    executor: aws-cli/default
    steps:
      - checkout
      - aws-cli/setup:
          profile-name: profile名
      - run:
          command: >
            aws s3 sync s3://本番環境/store/ s3://ステージング環境/store/ --delete --acl public-read --profile profile名
```
- `$ aws s3 sync`
  - 本番環境のストレージをステージング環境へ同期

### Workflows
```
workflows:
  # ...
  sync_production:
    triggers:
      - schedule:
          cron: '0 21 * * *' # UTC (JST AM 6:00)
          filters:
            branches:
              only:
                - main
    jobs:
      - restore_database
      - sync_s3
```
- `triggers`を利用してワークフローの定期実行を行う
  - [CircleCI を設定する > workflows > `workflow_name` > triggers](https://circleci.com/docs/ja/2.0/configuration-reference/#triggers)
- `branches`で処理を実行するブランチ(通常はmain)を指定する
  - 動作確認時はfeatureブランチへ変更する
