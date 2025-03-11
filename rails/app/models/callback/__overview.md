# コールバック
### オブジェクトのインスタンス化時
- `after_initialize`

### レコードの読み込み時
- `after_find` (`after_initialize`の前)

#### トリガ
- `all`
- `first`
- `find`
- `find_by`
- `find_by_*`
- `find_by_*!`
- `find_by_sql`
- `last`

### オブジェクトのcreate時
- `before_validation`
- `after_validation`
- `before_save`
- `around_save`
- `before_create`
- `around_create`
- `after_create`
- `after_save` (`after_create`の後)
- `after_create_commit` / `after_commit` / `after_rollback` (DBのトランザクション完了時)

#### トリガ
- `create`
- `create!`
- `save`
- `save!`
- `save(validate: false)`
- `valid?`

### オブジェクトのupdate時
- `before_validation`
- `after_validation`
- `before_save`
- `around_save`
- `before_update`
- `around_update`
- `after_update`
- `after_save` (`after_update`の後)
- `after_update_commit` / `after_commit` / `after_rollback` (DBのトランザクション完了時)

#### トリガ
- `update_attribute`
- `update`
- `update!`
- `save`
- `save!`
- `save(validate: false)`
- `toggle!`
- `valid?`

### オブジェクトのdestroy時
- `before_destroy` (`dependent: :destroy`より手前に記述する)
- `around_destroy`
- `after_destroy`
- `after_destroy_commit` / `after_commit` / `after_rollback` (DBのトランザクション完了時)

#### トリガ
- `destroy!`
- `destroy_all`
- `destroy_by`

### ActiveRecordオブジェクトのtouch時
- `after_touch`
