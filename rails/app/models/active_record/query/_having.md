# `having`
- 子レコードが存在しない親レコードを取得する
```ruby
Parent.left_outer_joins(:children).group('parents.id').having('count(children.id) = 0')
```

または

```ruby
Parent.left_outer_joins(:children).where(children: { id: nil })
```
