# ActiveRecord::Persistence
## `insert` / `upsert`
- `insert` -> `INSERT`文を発行する
- `upsert` -> `UPSERT`文を発行する(レコードが存在しない場合`INSERT`、存在する場合`UPDATE`)
- `create` `update`との違いは直接SQLを発行する点
  - バリデーションやコールバックはスキップされる

## 参照
- [`insert_all` and `upsert_all` ActiveRecord methods](https://frontdeveloper.pl/2020/03/insert_all-and-upsert_all-activerecord-methods/)
- [insert](https://github.com/rails/rails/blob/2f1fefe456932a6d7d2b155d27b5315c33f3daa1/activerecord/lib/active_record/persistence.rb#L66)
