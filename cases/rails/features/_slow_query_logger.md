# スロークエリのログを取得する
- ActiveSupport::Notificationsで指定のイベントにサブスクライブする機能を利用
- スロークエリが発生した際にログに出力する
- `config/initializer/slow_query_logger.rb`

```ruby
class SlowQueryLogger
  MAX_DURATION = 1.0 # 1.0秒を越すクエリが対象

  def self.initialize!(logger = Logger.new(STDOUT)) # 出力するロガーを指定

    # 'sql.active_record'を対象に監視する
    # name    イベント名(sql.active_record)
    # start   開始時のTimeオブジェクト
    # finish  終了時のTimeオブジェクト
    # id      イベントのユニークID
    # payload クエリの詳細を含むハッシュ

    ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
      duration = finish.to_f - start.to_f

      if duration >= MAX_DURATION # 開始から終了までがMAX_DURATIONを越す場合はログ出力
        logger.info("slow query detected: #{payload[:sql]}, duration: #{duration}, name: #{name}, id: #{id}")
      end
    end
  end
end

SlowQueryLogger.initialize!(Logger.new(Rails.root.join('log', "#{Rails.env}_slow_query.log"))) unless Rails.env.production?
```

## 参照
- [Rails tips: 遅いクエリのログをDB設定変更なしで取るコツ（翻訳）](https://techracho.bpsinc.jp/hachi8833/2018_04_26/55463)
