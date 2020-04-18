# Rack::QueryParser
- 引用: [rack/lib/rack/query_parser.rb](https://github.com/rack/rack/blob/master/lib/rack/query_parser.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
### `Rack::QueryParser#parse_query(qs, d = nil, &unescaper)`
- クエリ文字列を`&`と`;`で分割してパースする
- 2番目のパラメータで使用する文字を変更してクッキーを解析することもできる (デフォルトは`&;`)

### `Rack::QueryParser#parse_nested_query(qs, d = nil)`
- クエリ文字列を構造型に展開する
  - サポートされている型は配列、ハッシュ、その他基本的な値の型
  - 競合する型のパラメータを持つクエリ文字列を提供することができ、
    その場合はParameterTypeErrorが送出される
    - その場合400を返すことが推奨される
