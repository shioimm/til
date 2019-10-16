### inheritance_column=

- STI以外のテーブルでtypeというカラムを使用できるようにする
  - デフォルトではtypeはSTIを表現するための予約語のため使用できない

```ruby
self.inheritance_column = :_type_disabled
```

### ignored_columns=
- ARに対して隠蔽するカラムを設定する

```ruby
class Hoge < ApplicationRecord
  # fugaにアクセスすることができなくなる
  self.ignored_columns = %[fuga]
end

# 使い所
# STIの子モデルのうち、特定のモデルのみが使う属性に対してバリデーションをかけたい
# 他のモデルでは使わない属性のため、ignored_columnsで隠蔽する
```
