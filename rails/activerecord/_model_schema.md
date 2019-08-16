### inheritance_column=

- STI以外のテーブルでtypeというカラムを使用できるようにする
  - デフォルトではtypeはSTIを表現するための予約語のため使用できない
  - Ruby on Rails 5.2.3

```ruby
self.inheritance_column = :_type_disabled
```
