# Future
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第9章

## TL;DR
- Thread-Per-Messgaeにおいて、返り値が必要な場合に使用するパターン
- ClientがHostに依頼を渡すと、HostがClientにFuture(先物)を返す
  Client側はFutureに対してRealを呼び出す
  Realを返す条件が満たされている場合、実行結果が返る
  Realを返す条件が満たされておらず、満たされるまで待つ場合: Guarded Suspension
  Realを返す条件が満たされておらず、そのまま返す場合: Balking

### 文脈
- ClientがHostに対して処理を呼び出しているとき
- ClientはHostの処理の実行結果を得たいとき

### 問題
- Hostの処理の実行が終わるのを待っていると応答性が低下する

### 解決方法
- 処理の実行結果と同じインターフェースを持つFutureを作る
- ClientがHostに対して処理を呼び出した時点でHostはClientにFutureを返す
- 処理の実行結果が出たらFutureに返り値をセットする
- Clientは好きなタイミングでFutureを経由して処理の実行結果を得る

### 返り値の用意と返り値の返却の分離
- (前提)Thread-Per-Messageにおいて、
  依頼(Client)を行う役と実行を行う役(Host)が分離されていることにより、
  返り値の生成に時間がかかる
- 返り値の用意を行うための処理と実際に返り値を返却するための処理を分離する

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
  Realができていない場合はGuarded SuspensionかBalkingを使用する

## 再利用性
- マルチスレッドを意識する処理をHostとFutureに集約することで再利用性を高める

## パフォーマンス
- Realができるまでに時間がかかる処理(IO処理など)ではスループットが向上する

## 関連するパターン
- Buider
- Proxy
