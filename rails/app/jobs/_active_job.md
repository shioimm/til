# ActiveJob
- 参照: [Active Job の基礎](https://railsguides.jp/active_job_basics.html)

## TL;DR
- Railsにおけるジョブ管理を包括するジョブ管理インフラ
- 主に以下の機能を提供する
  - ジョブをメモリに保持するインプロセスのキューイングシステムとしての機能
  - キューイングバックエンドライブラリに接続するアダプタとしての機能
    - Sidekiq、Resque、Delayed Job etc
    - [Active Job adapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html)
  - ジョブにフックしたコールバックの実行

## ジョブのライフサイクル
1. キューイングバックエンドの選定・設定
2. キューイングバックエンドの起動
3. ジョブの作成
4. ジョブをキューへ登録
    - ジョブはRailsアプリケーションと並列で逐次実行される

## GlobalID
- ActiveRecordオブジェクトをジョブに渡すため、GlobalIDがパラメータとして使用されている
- GlobalIDにより、ActiveRecordオブジェクトを直接ジョブに渡すことが可能
```ruby
# GlobalIDがない場合
class BookPublishJob  < ApplicationJob
  def perform(book_class, book_id)
    book = trashable_class.constantize.find(book_id)
    book.publish
  end
end

# GlobalIDがある場合
class BookPublishJob  < ApplicationJob
  def perform(book)
    book.publish
  end
end
```
