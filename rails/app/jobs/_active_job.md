# ActiveJob
- Railsにおけるジョブ管理を包括するジョブ管理インフラ
- 主に以下の機能を提供する
  - ジョブをメモリに保持するインプロセスのキューイングシステムとしての機能
  - キューイングバックエンドライブラリに接続するアダプタとしての機能
    - Sidekiq、Resque、Delayed Job etc
    - [Active Job adapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)
  - ジョブにフックしたコールバックの実行(本番環境では上記のバックエンドを使用する)

#### ジョブのライフサイクル
1. キューイングバックエンドの選定・設定
2. キューイングバックエンドの起動
3. ジョブの作成
4. ジョブをキューへ登録
    - ジョブはRailsアプリケーションと並列で逐次実行される

## Usage
#### ジョブの生成

```
$ rails generate job xxx(ジョブ名)
```

```ruby
class FooJob < ApplicationJob
  queue_as :default
  # 別のキューを使用する場合はキュー名を指定 (ActionMailerが使用するキュー名はデフォルトで:mailers)

  def perform(*args)
    # 非同期で行う処理
  end

  retry_on {捕捉する例外}, wait: {待機時間}, attempts: {リトライ回数}, queue: {キュー名}, priority: {優先度}
  # 利用するバックエンド側でリトライ機構を持っている場合、両方実行されないように気をつける

  discard_on {ジョブを破棄する例外}
end
```

#### ジョブの利用

```ruby
FooJob.perform_later(args)
FooJob.set(wait: 1.minute).perform_later(args)
FooJob.set(wait_until: Time.current + 1.minute).perform_later(args)
FooJob.set(queue: xxx_queue).perform_later(args)
```

#### キューアダプターの設定

```ruby
# config/application.rb(config/environments/production.rb)

module FooApp
  class Application < Rails::Application
    config.active_job.queue_adapter = :{バックエンド}
  end
end
```

| 設定値         | ジョブキューライブラリ | バックエンド      |
| -              | -                      | -                 |
| `:sidekiq`     | Sidekiq                | Redis             |
| `:shoryuken`   | Shoryuken              | SQS               |
| `:solid_queue` | Solid Queue            | SQS, PostgreSQL   |
| `:amazon_sqs`  | SQS (`aws-sdk-rails`)  | SQS               |
| `:delayed_job` | Delayed Job            | PostgreSQL, MySQL |
| `:async`       | Rails内蔵の簡易キュー  | メモリ            |
| `:inline`      | 即時実行               | なし              |

## ジョブに渡せる引数
- 基本型
- Symbol
- 日時を扱う型
- Hash / ActiveSupport::HashWithIndifferentAccess
- Array
- ActiveRecord

#### GlobalID
- ActiveRecordオブジェクトはGlobalIDによってURI文字列にシリアライズされた後ジョブに渡される
  - `ActiveRecordオブジェクト.to_grobal_id`

```ruby
# GlobalIDを使用しない場合
class BookPublishJob  < ApplicationJob
  def perform(book_class, book_id)
    book = trashable_class.constantize.find(book_id)
    book.publish
  end
end

# GlobalIDを使用できる場合
class BookPublishJob  < ApplicationJob
  def perform(book)
    book.publish
  end
end
```

- ActiveRecordオブジェクトをキューから取り出す際は
  GlobalID::Locatorによってモデルオブジェクトにデシリアライズする
  - `GlobalID::Locator.locate(global_id)`
- ActiveJobを使用せずバックエンドを直接使用する場合、
  シリアライズ・デシリアライズ処理は自動で行われないため
  自力でシリアライザを実装する必要がある

## 参照
- [Active Job の基礎](https://railsguides.jp/active_job_basics.html)
- パーフェクトRuby on Rails[増補改訂版] P216-224
