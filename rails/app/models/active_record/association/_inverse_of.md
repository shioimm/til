# `inverse_of`
- ActiveRecordで双方向の関連付けをするとき、`inverse_of`オプションを使用することによって、
関連が同じオブジェクトを指していることを明示する
  - Rails4.1 以降はデフォルトで指定されている

### 使い所
- `foreign_key` `order`などのオプションを使用している場合
```ruby
class Customer < User
  has_many :valid_addresses,
           -> { where(validity: true) },
           inverse_of: :customer, class_name: 'Address', foreign_key: 'customer_id',
           dependent: :destroy
end
```

```ruby
class Address < ApplicationRecord
  belongs_to :customer, inverse_of: :valid_addresses, class_name: 'Customer'
end
```

## 参照
- [`inverse_of` について](https://qiita.com/itp926/items/9cac175d3b35945b8f7e)
