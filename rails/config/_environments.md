# 環境に依存する設定
## `cache_store`
- 参照: [2 キャッシュストア](https://railsguides.jp/caching_with_rails.html#%E3%82%AD%E3%83%A3%E3%83%83%E3%82%B7%E3%83%A5%E3%82%B9%E3%83%88%E3%82%A2)
- キャッシュデータの保存場所
```ruby
Rails.application.configure do
  config.cache_store = :memory_store, { size: 64.megabytes }
  # Rails.cache でアクセスできる
end
```
- :memory_store
  - キャッシュを同じRubyプロセス内のメモリに保持する
- :file_store
  - キャッシュをファイルシステムに保存する
  - 保存先のパスの指定が必要
- :mem_cache_store
  - キャッシュをDangaのmemcachedサーバーに一元化保存する
- :redis_cache_store
  - メモリ最大使用量に達した場合の自動エビクションをサポートし、
    Memcachedキャッシュサーバーのように振る舞う
  - redis gemの追加とRedis URLが必要
- :null_store
  - キャッシュを一切保存しない

### キャッシュの種類
- 参照: [Rails のキャッシュ機構](https://railsguides.jp/caching_with_rails.html)
- 引用: [キャッシュってなんだ！わかんないから調べてみた](https://blog-tech.fukurou-labo.co.jp/2018/06/08/rails/%E3%82%AD%E3%83%A3%E3%83%83%E3%82%B7%E3%83%A5%E3%81%A3%E3%81%A6%E3%81%AA%E3%82%93%E3%81%A0%EF%BC%81%E3%82%8F%E3%81%8B%E3%82%93%E3%81%AA%E3%81%84%E3%81%8B%E3%82%89%E8%AA%BF%E3%81%B9%E3%81%A6%E3%81%BF/)

#### ビューキャッシュ
- フラグメントキャッシュ
  - ページを構成するコンポーネントを個別にキャッシュ
- コレクションキャッシュ
  - renderヘルパーにおいて、collectionを指定し個別のテンプレートに対してキャッシュ
- ロシアンドールキャッシュ
  - フラグメントキャッシュ内で、ネストしたフラグメントをキャッシュ
- ページキャッシュ
  - Webサーバーによって生成されるページへのリクエストをキャッシュ
  - actionpack-page_caching gem
- アクションキャッシュ
  - Webサーバーによって生成されるページへのリクエストをbefore_filter実行後にキャッシュ
  - actionpack-action_caching gem

#### モデル・コントローラで使うキャッシュ
- 低レベルキャッシュ
  - 特定の値やクエリをキャッシュ
  - `Rails.cache.fetch`メソッドを利用する

#### SQLキャッシュ
- クエリキャッシュ
  - 各クエリによって返った結果セットをRailsが自動的にキャッシュ
  - アクションの開始時に作成され、アクションの終了時に破棄される
