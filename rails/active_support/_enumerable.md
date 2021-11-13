# Enumerable
#### `index_with(default = INDEX_WITH_DEFAULT)`
- 配列の要素をkey、ブロック内の返り値をvalueとしてハッシュに変換する
- `#each_with_object({})`に代用できる

```ruby
# Before
book = Book.new(title: 'Programming Ruby', author: 'Dave Thomas')

%i[title author].each_with_object({}) do |attr, hash|
  hash[attr] = post.public_send(attr)
end
# => { title: 'Programming Ruby', author: 'Dave Thomas' }

# After
book = Book.new(title: 'Programming Ruby', author: 'Dave Thomas')

%i[title author].index_with { |attr| post.public_send(attr) }
# => { title: 'Programming Ruby', author: 'Dave Thomas' }
```
