# enum
### enumを使用するカラムにnull制約をつけたい
- enumの初期値を用意する
```ruby
class CreateInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :informations do |t|
      t.integer :kind, null: false, default: 0
    end
  end
end
```
```ruby
class Information < ApplicationRecord
  enum status: { initial: 0 }
end
```
