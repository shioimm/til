# バリデーション
### ヘルパー
- `absence`
- `acceptance`
- `comparison`
- `confirmation`
- `exclusion`
- `format`
- `inclusion`
- `length`
- `numericality`
- `presence`
- `uniqueness`
- `validates_associated`
- `validates_each`
- `validates_with`

#### オプション
- `:allow_blank`
- `:allow_nil`
- `:message` (エラーメッセージ)
- `:on` (実施タイミング)
- `:strict` (バリデーションエラー時に`ActiveModel::StrictValidationFailed`を送出)
- `:if`
- `:unless`

### `inclusion`

```ruby
# boolean型のカラムに対してpresenceヘルパーを使用すると値がfalseの場合にvalid? => falseになる
# 代わりにinclusionヘルパー / :inオプションを使用する
# 属性flagがtrue || falseであること(値を含んでいることによって存在を担保する)

validates :flag, inclusion: { in: [true, false] }
```

### `validates_uniqueness_of`

```ruby
# uniquenessバリデーションに条件をつける
validates_uniqueness_of :title, conditions: -> { where.not(status: :archived) }

# 複数のscope
validates_uniqueness_of :title, scope: %i[genre publisher_id] }
```

### `validate_associated`
- モデルが他のモデルに関連付けられており、両方のモデルに対してバリデーションを実行する
- 関連付けの片側のオブジェクトにのみ記述する (関連付けの両側で使用すると無限ループになる)
- エラーが発生した際は`validates_associated`を記述した方のモデルオブジェクトにエラーが入る

```ruby
class Book < ApplicationRecord
  has_many :chapters
  validates_associated :chapters
end
```

## 参照
- [Active Record バリデーション](https://railsguides.jp/active_record_validations.html#inclusion)
- [ActiveRecord::Validations::ClassMethods](https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of)
- [2.2 `validates_associated`](https://railsguides.jp/active_record_validations.html#validates-associated)
