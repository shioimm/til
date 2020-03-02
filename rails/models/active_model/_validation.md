# ActiveModel::Validations
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP426-427
- バリデーション機能を提供する
- `errors`メソッドを提供する
  - DBとの接続が必要なバリデーションはActiveRecordによって提供されている

### boolean型のカラムに対してpresenceバリデーションをかけたい
- boolean型のカラムに対して`presence`ヘルパーを使用すると、
値が`false`の場合に`valid? # => false`になる
- 代わりに`inclusion`ヘルパーと`:in`オプションを使用する
```ruby
# 属性hogeがtrue || falseであること(値を含んでいることによって存在を担保する)
validates :hoge, inclusion: { in: [true, false] }
```
- 参照: [Active Record バリデーション](https://railsguides.jp/active_record_validations.html#inclusion)

### uniquenessバリデーションに条件をつけたい
- `conditions`オプションを使用する
```ruby
validates_uniqueness_of :title, conditions: -> { where.not(status: 'archived') }
```
- 参照: [ActiveRecord::Validations::ClassMethods](https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of)

### 関連するモデルに対してもバリデーションチェックを行いたい
- 参照: [2.2 validates_associated](https://railsguides.jp/active_record_validations.html#validates-associated)
- `validates_associated`を使用する
```ruby
class Author < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

#### 事例
- マスターデータを登録する際、同時に関連データを保存したい
```
class MasterData < ApplicationRecord
  has_many :datas
  before_create :build_related_datas
  validates_associated :datass

  def build_related_datas
    self.datas.build(...)
  end

  # master_dataをsaveした際、同時に関連するdatasもsaveされる
  # dataがinvalidである場合、バリデーションエラーが発生する
end
```
