# Rack::ConditionalGet
- 引用: [rack/lib/rack/conditional_get.rb](https://github.com/rack/rack/blob/master/lib/rack/conditional_get.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- レスポンスが変更されていない場合に、変更されていないままのレスポンスを返すミドルウェア
- If-None-MatchおよびIf-Modified-Sinceを利用した条件付きGETを有効にする
  - アプリケーションはRFC 2616に従ってLast-Modifiedレスポンスヘッダ・Etagレスポンスヘッダのどちらかまたは両方を
    設定する必要がある
  - いずれかの条件が満たされた場合、レスポンスボディの長さは0になり、
    ステータスコードは304 Not Modifiedに設定される
  - 各メッセージのボディが受信されるまでレスポンスボディの生成を遅延するアプリケーションについては、
    条件付きGETがマッチする場合レスポンスボディは生成されない

## `Rack::ConditionalGet#call`
- 最後のリクエスト以降、レスポンスが変更されていない場合は、空の304レスポンスを返す
