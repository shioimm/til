# ActiveSupport::Cache::Store API
- `cache_store`に設定したストアに対する操作をまとめたAPI

#### キャッシュストアの設定
```ruby
rails.application.configure do
  config.cache_store = :memory_store, { size: 64.megabytes }
end

# 設定可能なキャッシュストア
# :memory_store / :file_store / :mem_cache_store / :redis_cache_store / :null_store`
```

#### `Rails.cache.fetch`
- キャッシュの書き込みと読み出しを行う
- キャッシュにヒットした場合:
  - キャッシュの値を返す
- キャッシュにヒットしなかった場合:
  - `nil`を返す
- キャッシュにヒットしなかった場合かつブロック引数として渡されている場合:
  - ブロックが実行され、ブロックの戻り値を指定のキャッシュキーの値として書き込む

#### `Rails.cache.delete`
- キャッシュの削除を行う
- 削除に成功した場合:
  - `true`を返す

#### `Rails.cache.exist?`
- キャッシュの存在を確認する
