# `order`
- ASC - デフォルトで値がNULLのレコードが行列の最後に位置する
- DESC - デフォルトで値がNULLのレコードが行列の最初に位置する

```ruby
# PostgreSQL

Book.order('books.price asc nulls first')
Book.order('books.price desc nulls last')
```

- `scope`で`order`が設定されている場合、
  取得したレコードに対して`order`しても実行されない(`scope`側の`order`が優先される)

```ruby
scope :out_of_print, (-> {
  where(out_of_print: true)
    .order(published_at: :asc)
})

Book.out_of_print.order(published_at: :desc)   # => published_at: :asc
Book.out_of_print.reorder(published_at: :desc) # => published_at: :desc
```
