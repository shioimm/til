# キャッシュ機構
- [Rails のキャッシュ機構](https://railsguides.jp/caching_with_rails.html)

## キャッシュストアの設定
```ruby
Rails.application.configure do
  config.cache_store = :memory_store, { size: 64.megabytes }
end
```

- `:memory_store`
  - キャッシュを同じRubyプロセス内のメモリに保持する
- `:file_store`
  - キャッシュをファイルシステムに保存する
  - 保存先のパスの指定が必要
- `:mem_cache_store`
  - キャッシュをDangaのmemcachedサーバーに一元化保存する
- `:redis_cache_store`
  - メモリ最大使用量に達した場合の自動エビクションをサポートし、
    Memcachedキャッシュサーバーのように振る舞う
  - redis gemの追加とRedis URLが必要
- `:null_store`
  - キャッシュを一切保存しない

## キャッシュの種類
### 低レベルキャッシュ
  - 特定の値やクエリをキャッシュする
  - `Rails.cache`で直接キャッシュストアへアクセスする

### SQLキャッシュ
- 各クエリによって返った結果セットをRailsが自動的にキャッシュする
- アクションの開始時に作成され、アクションの終了時に破棄される

### Viewのためのキャッシュ
- フラグメントキャッシュ
  - ページを構成するコンポーネントを個別にキャッシュする
- コレクションキャッシュ
  - `render`ヘルパーで`collection`を指定し個別のテンプレートに対してキャッシュする
- ロシアンドールキャッシュ
  - フラグメントキャッシュ内でネストしたフラグメントをキャッシュする
- ページキャッシュ
  - Webサーバーによって生成されるページへのリクエストをキャッシュする
  - `actionpack-page_caching` gem
- アクションキャッシュ
  - Webサーバーによって生成されるページへのリクエストを`before_filter`実行後にキャッシュする
  - `actionpack-action_caching` gem

## ActiveSupport::Cache::Store API
### `Rails.cache.fetch`
- キャッシュの書き込みと読み出しを行う
- キャッシュにヒットした場合:
  - キャッシュの値を返す
- キャッシュにヒットしなかった場合:
  - `nil`を返す
- キャッシュにヒットしなかった場合かつブロック引数として渡されている場合:
  - ブロックが実行され、ブロックの戻り値を指定のキャッシュキーの値として書き込む

### `Rails.cache.delete`
- キャッシュの削除を行う
- 削除に成功した場合:
  - `true`を返す

### `Rails.cache.exist?`
- キャッシュの存在を確認する
