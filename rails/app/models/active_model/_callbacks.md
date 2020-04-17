# ActiveModel::Callbacks
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP426-427
- 参照: https://github.com/rails/rails/tree/master/activemodel
- 参照: https://railsguides.jp/active_model_basics.html#callbacks%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB
- コールバックを定義できるようになる
- extendすることでPOROでコールバックを使用できるようになる
- ActiveModel::Validations::Callbacksと併せてincludeするとバリデーション系のコールバックも利用できるようになる

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
before_destroy :bitten_biscuit?

def bitten_biscuit?
  if self.biscuit.bitten?
    throw :abort
  end
end

# 使い所
# 不可逆的な処理を行った後のレコードを削除したくない場合など
```
