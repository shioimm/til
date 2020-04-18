# Rack::Events
- 引用: [rack/lib/rack/events.rb](https://github.com/rack/rack/blob/master/lib/rack/events.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- リクエスト/レスポンスのライフサイクルの特定の場所にフックを提供するミドルウェア
  - これによりレスポンスデータをフィルタリングする必要のないミドルウェアは安全にデータを残すことができ、
    従来の"rack stack"でメッセージを送信する必要がなくなる

### `on_start(request, response)`
- リクエストの開始時に送信され、次のミドルウェアが呼ばれる前に実行されるイベント
- このメソッドはRequestオブジェクトとResponseオブジェクトから呼び出される
  - 今のところResponseオブジェクトは常にnil
    - 将来的には実際のResponseオブジェクトになる可能性もある

### `on_commit(request, response)`
- アプリケーションが返っているが、レスポンスがまだWebサーバに送信されていない時点で実行されるイベント
- このメソッドは常にRequestオブジェクトとResponseオブジェクトと共に呼び出される
  - Responseオブジェクトはアプリケーションが返したRack tripleから構築される
    - この時点でもResponseオブジェクトに変更を加えることができる

### `on_send(request, response)`
- Webサーバがレスポンスボディのイテレーション処理を開始し、
  有線でのデータ送信を開始した時点で実行されるイベント
- このメソッドは常にRequestオブジェクトとResponseオブジェクトと共に呼び出される
  - Responseオブジェクトはアプリケーションが返したRack tripleから構築される
  - Webサーバはすでにデータの送信を開始しているため、Responseオブジェクトには変更を加えるべきではない。 
    - Responseオブジェクトに変更があった場合、例外が発生する可能性が高い

### `on_finish(request, response)`
- Webサーバがレスポンスを閉じ、すべてのデータがレスポンスソケットに書き込まれた時点で実行されるイベント
  - この時点でRequestオブジェクトとResponseオブジェクトはどちらも読み込み専用になっている(はずである)
  - Responseオブジェクトのボディはソケットにフラッシュされている可能性があるため、利用できない

### `on_error(request, response, error)`
- アプリケーションもしくは`on_commit`イベントで例外が発生した場合に実行されるイベント
- このメソッドはRequestオブジェクト、Responseオブジェクト(存在する場合)、
  発生した例外オブジェクトを取得する

### 実行順序
- `on_start` はコンストラクタに渡された順にハンドラから呼び出される
- `on_commit`/`on_send`/`on_finish`/`on_error`は逆の順番で呼び出される
- `on_finish`ハンドラは`ensure`ブロック内で呼び出されるため、例外が発生しても必ず実行される
- `on_finish`メソッドで例外が発生した場合は何も保証されない
