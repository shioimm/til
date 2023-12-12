# `ActiveRecord::ConnectionAdapters::SchemaCache`
- データベーススキーマに関する情報のキャッシュ

```
schema_cache = ActiveRecord::ConnectionAdapters::SchemaCache.new(ActiveRecord::Base.connection)

schema_cache.primary_keys("<テーブル名>")
schema_cache.columns("<テーブル名>")
schema_cache.indexes("<テーブル名>")
```
