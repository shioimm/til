# `order`
- ASC - デフォルトで値がNULLのレコードが行列の最後に位置する
- DESC - デフォルトで値がNULLのレコードが行列の最初に位置する

```ruby
# PostgreSQL

Book.order('books.price asc nulls first')
Book.order('books.price desc nulls last')
```
