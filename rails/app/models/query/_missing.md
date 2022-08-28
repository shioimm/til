# `missing`
- 関連元Foo - 関連先Bar
- Barレコードを持たないFooレコード一式を取得する

```ruby
Foo.where.missing(:bar)
```

または

```ruby
Foo.left_outer_joins(:bar).where(bar: { id: nil })
```
