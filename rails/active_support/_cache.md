# ActiveSupport::Cache::Store API
- `cache_store`に設定したストアに対する操作をまとめたAPI

```ruby
# キャッシュの書き込みと読み出しを行う
Rails.cache.fetch
# キャッシュにヒットした場合: キャッシュの値を返す
# キャッシュにヒットしなかった場合: nil`を返す
# キャッシュにヒットせずブロック引数が渡されている場合:
#   ブロックが実行され、ブロックの戻り値を指定のキャッシュキーの値として書き込む

# keyと一致するキャッシュの削除を行う
Rails.cache.delete(key) # 完全一致
Rails.cache.delete_match(key) # 部分一致
# 削除に成功した場合: trueを返す

# keyと一致するキャッシュの存在を確認する
Rails.cache.exist?(key)
```

## キャッシュストアの設定
```ruby
rails.application.configure do
  config.cache_store = :memory_store, { size: 64.megabytes }
end

# 設定可能なキャッシュストア
# :memory_store / :file_store / :mem_cache_store / :redis_cache_store / :null_store`
```
