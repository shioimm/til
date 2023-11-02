# CSVから大量データをDBに投入する

```ruby
books = []

CSV.foreach('db/fixtures/books.csv').with_index do |row, i|
  next if i.zero?

  books << {
    id: row[0],
    title: row[1],
    author_id: row[2],
    genre: row[3],
    created_at: row[4],
    updated_at: row[5],
  }
end

Book.insert_all books
```
