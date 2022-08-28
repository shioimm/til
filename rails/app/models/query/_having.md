# `having`
- 関連元Foo - 関連先Bar
- Barレコードを持たないFooレコード一式を取得する

```ruby
Foo.left_outer_joins(:bar).group('foo.id').having('count(bar.id) = 0')
```

または

```ruby
Foo.left_outer_joins(:bar).where(bar: { id: nil })
```
