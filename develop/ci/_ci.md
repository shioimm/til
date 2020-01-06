# Continuous integration
- 引用・参照: [Ruby on Rails set up on Github with CircleCI](https://hixonrails.com/ruby-on-rails-tutorials/ruby-on-rails-set-up-on-github-with-circleci/)
- CIは、開発者がコードを共有リポジトリに継続的にpushすることを前提とした開発手法

#### CIによって自動化できること
- ビルド
- テストの実行
- 静的コード解析の実行
- 脆弱性の検出
- エラーの検出etc

#### よく使用されているCIツール
- 参照: [CIマニアから見た各種CIツールの使い所](https://sue445.hatenablog.com/entry/2018/12/07/114638)
- TravisCI
  - デフォルトのビルドとテストの設定がシンプル
  - 各バージョン毎のマトリクステストが書きやすい
- CitrcleCI
  - 複雑なワークフローの設定を行うことができる

### CircleCIの設定
1. GitHubアカウントで[CircleCI](https://circleci.com/signup/)に登録
2. Add Projectタブを選択
3. Set up projectボタンを押下
4. アプリケーションのルート直下に`config/database.yml`を作成
```yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV['DB_POOL'] %>
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] %>
  port: 5432

development:
  <<: *default
  database: rails_app_name_development

test:
  <<: *default
  database: rails_app_name_test

production:
  <<: *default
  database: rails_app_name_production
```
5. アプリケーションのルート直下に`.circleci/config.yml`を作成し、基本の設定を記述
```
version: 2.1

executors:
  default:
    working_directory: ~/rails_app_name
    docker:
      - image: circleci/ruby:2.6.5 # Rubyのバージョンを指定
        environment:
          BUNDLE_JOBS: 3
          BUNDLE_PATH: vendor/bundle
          BUNDLE_RETRY: 3
          BUNDLER_VERSION: 2.0.1 # Bundlerのバージョンを指定
          RAILS_ENV: test
          DB_HOST: 127.0.0.1
          PG_HOST: 127.0.0.1
          PGUSER: railsappname # PGユーザー名(必須ではない)
      - image: circleci/postgres:12.0 # PGのバージョンを指定
        environment:
          POSTGRES_DB: rails_app_name_test
          POSTGRES_USER: railsappname # PGユーザー名(必須ではない)

commands:
  configure_bundler:
    description: Configure bundler
    steps:
      - run:
          name: Configure bundler
          command: |
            echo 'export BUNDLER_VERSION=$(cat Gemfile.lock | tail -1 | tr -d " ")' >> $BASH_ENV
            source $BASH_ENV
            gem install bundler

jobs:
  build:
    executor: default
    steps:
      - checkout
      - restore_cache:
          keys:
            - rails_app_name-{{ .Branch }}-{{ checksum "Gemfile.lock" }}
            - rails_app_name-
      - configure_bundler
      - run:
          name: Install bundle
          command: bundle install
      - run:
          name: Wait for DB
          command: dockerize -wait tcp://127.0.0.1:5432 -timeout 1m
      - run:
          name: Setup DB
          command: bundle exec rails db:create db:schema:load --trace
      - save_cache:
          key: rails_app_name-{{ .Branch }}-{{ checksum "Gemfile.lock" }}
          paths:
            - vendor/bundle
      - persist_to_workspace:
          root: ~/
          paths:
            - ./rails_app_name

workflows:
  version: 2
  integration:
    jobs:
      - build
```
6. `.circleci/config.yml`にRSpecの設定を追加
```yml
jobs:
  build:
    executor: default
    steps:
      - checkout
      - restore_cache:
          keys:
            - rails_app_name-{{ .Branch }}-{{ checksum "Gemfile.lock" }}
            - rails_app_name-
      - configure_bundler
      - run:
          name: Install bundle
          command: bundle install
      - run:
          name: Wait for DB
          command: dockerize -wait tcp://127.0.0.1:3306 -timeout 1m
      - run:
          name: Setup DB
          command: bundle exec rails db:create db:schema:load --trace
      - run:
          name: RSpec
          command: |
            bundle exec rspec --profile 10 \
                              --format progress
      - store_artifacts:
          path: coverage
      - save_cache:
          key: rails_app_name-{{ .Branch }}-{{ checksum "Gemfile.lock" }}
          paths:
            - vendor/bundle
      - persist_to_workspace:
          root: ~/
          paths:
            - ./rails_app_name

workflows:
  version: 2
  integration:
    jobs:
      - build
```
7. `.circleci/config.yml`にRubocopの設定を追加
```yml
  rubocop:
    executor: default
    steps:
      - attach_workspace:
          at: ~/
      - configure_bundler
      - run:
          name: Rubocop
          command: bundle exec rubocop

workflows:
  version: 2
  integration:
    jobs: 
      - build
```
8. `.circleci/config.yml`にBrakemanの設定を追加
```yml
brakeman:
    executor: default
    steps:
      - attach_workspace:
          at: ~/
      - configure_bundler
      - run:
          name: Brakeman
          command: bundle exec brakeman

workflows:
  version: 2
  integration:
    jobs:
      - build
      - brakeman:
          requires:
            - build
```
