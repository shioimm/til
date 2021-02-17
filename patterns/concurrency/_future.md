# Future
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第9章

## TL;DR
- 処理を返り値を用意することと処理の返り値の利用を分離したThread-Per-Message
- Client側がHost側にリクエストを送信する
  Host側がClient側からリクエストを受信するとFuture(先物)を返す
- Client側はFutureを受け取った後Futureに対して処理を実行しようとする
  条件が満たされていれば実行結果が返る
  条件が満たされていなければ満たされるまで待つ or そのまま返す
- Futureに対して処理を実行した時、
  条件が満たされていなければ満たされるまで待つ場合: FutureがGuarded Suspensionを使用する
  条件が満たされていなければそのまま返す場合: FutureがBalkingを使用する

## 要素
### Client
- Hostに対してリクエストを送信する
  リクエストの返り値としてFutureを受信する

### Host
- Clientからリクエストを受信し、新しいスレッドを生成してRealを作り始める
  ClientへFutureを返す

### Real
- 実際の返り値となるオブジェクト
- 生成に時間がかかる
- 生成後、Futureから呼ばれた処理を実行する

### Future
- Realの先物としてHostからClientに渡されるオブジェクト
- Clientから操作された際、Realができている場合はRealに対してその処理を移譲する
  Realができていない場合は`wait`する

## 再利用性
- マルチスレッドを意識する処理をHostとFutureに集約することで再利用性を高める

## パフォーマンス
- Realができるまでに時間がかかる処理(IO処理など)ではスループットが向上する

## 関連するパターン
- Thread-Per-Message
- Buider
- Proxy
- Guarded Suspension
- Balking
