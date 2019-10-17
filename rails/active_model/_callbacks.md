### Callbackモジュール

- ActiveModel::CallbacksをextendすることでPOROでコールバックを使用できるようになる
- https://github.com/rails/rails/tree/master/activemodel
- https://railsguides.jp/active_model_basics.html#callbacks%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB

```ruby
class Hoge
  extend ActiveModel::Callbacks

  define_model_callbacks :create

  before_create :fuga

  def create
    run_callbacks :create do
      # createメソッドの内容を記述する
    end
  end

  def fuga
    # createの直前に実行される
  end
end
```

- `define_model_callbacks :create`で`before_create`、 `around_create`、 `after_create`が使用できるようになる
- コールバックは`extend ActiveModel::Callbacks`よりも下に記述する

### コールバックを停止する
- 参照: [6 コールバックの停止](https://railsguides.jp/active_record_callbacks.html#%E3%82%B3%E3%83%BC%E3%83%AB%E3%83%90%E3%83%83%E3%82%AF%E3%81%AE%E5%81%9C%E6%AD%A2)
- コールバックに`throw :abort`を記述することで操作を停止し、ロールバックを行うことができる
```ruby
before_destroy
  if self.associated_records.present?
    throw :abort
  end
end

# 使い所
# レコードが関連レコードを持っていない場合のみ削除を許容する
```
