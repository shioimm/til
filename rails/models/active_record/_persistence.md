# ActiveRecord::Persistence
## `insert` / `upsert`
- 参照: [`insert_all` and `upsert_all` ActiveRecord methods](https://frontdeveloper.pl/2020/03/insert_all-and-upsert_all-activerecord-methods/)
- 参照: [insert](https://github.com/rails/rails/blob/2f1fefe456932a6d7d2b155d27b5315c33f3daa1/activerecord/lib/active_record/persistence.rb#L66)
- `insert` -> `INSERT`文を発行する
- `upsert` -> `UPSERT`文を発行する(レコードが存在しない場合`INSERT`、存在する場合`UPDATE`)
- `create` `update`との違いは直接SQLを発行する点
  - バリデーションやコールバックはスキップされる
### 実装(2020/3/11時点)
```ruby
# https://github.com/rails/rails/blob/2f1fefe456932a6d7d2b155d27b5315c33f3daa1/activerecord/lib/active_record/persistence.rb#L66
def insert(attributes, returning: nil, unique_by: nil)
  insert_all([ attributes ], returning: returning, unique_by: unique_by)
end
```
```ruby
# https://github.com/rails/rails/blob/2f1fefe456932a6d7d2b155d27b5315c33f3daa1/activerecord/lib/active_record/persistence.rb#L187
def upsert(attributes, returning: nil, unique_by: nil)
  upsert_all([ attributes ], returning: returning, unique_by: unique_by)
end
```
- メソッドの中でそれぞれ`insert_all` `upsert_all`を呼ぶ
- `returning`オプションは`INSERT`成功時の返り値となるレコードの属性を指定する(PostgreSQLのみ)
- `unique_by`オプションは重複時にスキップするカラムを指定する(PostgreSQL/SQLiteのみ)
