# `aliases`
- モデルに別名をつける

```ruby
factory :user, aliases: [:author, :commenter] do
  name { "John" }
end

factory :post do
  author
  title { "..." }
  body  { "..." }
end

factory :comment do
  commenter
  body { "..." }
end
```

## 引用
- [Aliases](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#aliases)
