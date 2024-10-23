# キャッシュ機構
- [Rails のキャッシュ機構](https://railsguides.jp/caching_with_rails.html)

## キャッシュの種類
### 低レベルキャッシュ
- 特定の値やクエリのキャッシュ
- 指定のキャッシュストアに保存され、ActiveSupport::Cache::Store APIで操作できる

### SQLキャッシュ (クエリキャッシュ)
- DBから各クエリによって得られた結果セットのキャッシュ
- デフォルトで有効化
- アクションの開始時に作成され、アクションの終了時に破棄される

### Viewのためのキャッシュ
- フラグメントキャッシュ
  - ページを構成するコンポーネントを個別にキャッシュする
  - `AbstractController::Caching::Fragments`でキャッシュを操作できる
    - e.g. `expire_fragment(<キャッシュキー>)`
- コレクションキャッシュ
  - `render`ヘルパーで`collection`を指定し個別のテンプレートに対してキャッシュする
- ロシアンドールキャッシュ
  - フラグメントキャッシュ内でネストしたフラグメントをキャッシュする
- ページキャッシュ
  - デフォルトで有効化
  - Webサーバーによって生成されるページへのリクエストをキャッシュする
  - `actionpack-page_caching` gem
- アクションキャッシュ
  - Webサーバーによって生成されるページへのリクエストを`before_filter`実行後にキャッシュする
  - `actionpack-action_caching` gem

## キャッシュストアの設定
```ruby
rails.application.configure do
  config.cache_store = :memory_store, { size: 64.megabytes }
end
```

- ストアに保存したキャッシュはActiveSupport::Cache::Store APIで操作可能

#### 指定できるストア
- `:memory_store` - キャッシュを同じRubyプロセス内のメモリに保持する
- `:file_store` - キャッシュをファイルシステムに保存する (保存先のパスを指定する)
- `:mem_cache_store` - キャッシュをDangaのmemcachedサーバーに一元保存する
- `:redis_cache_store` - キャッシュをRedisサーバーに一元保存する (redis gemの追加とRedis URLが必要)
- `:null_store` - キャッシュを一切保存しない
