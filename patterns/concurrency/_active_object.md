# Active Object
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第12章

## TL;DR
- 能動的なオブジェクト群によるパターン
- 能動的なオブジェクトは外部から受け取った非同期メッセージを
  自分固有のスレッドで自分の都合の良いタイミングで処理する
- Producer-Consumer(データ生成と処理の分離)、
  Thread-Per-Message(データ処理の生成と実行の分離)、
  Future(処理の実行と実行結果の受け取りの分離)を組み合わせて構成する
- Actorパターンと呼ばれる

## 特徴
- 外部からの依頼を非同期に受け取る
- 自由なスケジューリングができる
- 実際の処理はシングルスレッドで行うことができる
- 実行結果を返せる
- 独立したスレッドを持つ

## スレッドの種類
- ClientとSchedulerの二種類のスレッドが独立して処理を行う
  - 処理の呼び出しはClientのスレッドによって行われる
    - Client -> (ActiveObject) -> Proxy -> (MethodRequest) -> Scheduler( -> ActivationQueue)
  - 処理の実行はSchedulerのスレッドによって行われる
    - ActivationQueue -> (MethodRequest) -> Scheduler -> Servant( -> RealResult -> Client)
- スレッドの種類が分離している = 分散処理

## 利用ケース
- 処理を依頼する側(Client)と処理を実行する側(Scheduler)が分かれている
  どちらかの処理の遅延でもう片方に影響を与えたくない
- 処理を依頼する側から処理を実行する側へ向かうワークフローと
  処理を実行する側から処理を依頼する側へ向かうワークフローがある

## 要素
### Client(依頼者)
- ActiveObjectのメソッドを呼び出し、処理を依頼する
- ActiveObjectが提供するAPIにのみアクセスする
  - ClientはActiveObjectが提供するAPIを通じてProxyの処理を呼び出す
- 処理の返り値としてVirtualResultを受け取り、
  VirtualResultに対して処理を実行するとRealResultを受け取る
  (Future)

### ActiveObject（能動的なオブジェクト)
- 能動的なオブジェクトからClientへ提供されるAPI集

### Proxy(代理人)
- Clientからの処理の呼び出しをMethodRequestオブジェクトに変換する
  - 変換されたMethodRequestはSchedulerに渡される
- ActiveObjectがClientに対して提供しているAPIを実装している
- 複数のスレッドから同時に呼び出される

### Scheduler
- Proxyから渡されたMethodRequestをActivationQueueにエンキューする
- ActivationQueueからMethodRequestをデキューし、Servantに対して処理の実行を委譲する
- ActivationQueueに対してMethodRequestを出し入れすることでスケジューリング機能を担う

### MethodRequest
- Clientからの処理の呼び出しをオブジェクトに対応させたもの
  - Servantが実行する
  - Futureが返り値を書き込む
  - 処理を実行するためのAPIを提供する

#### ConcreteMethodRequest
- MethodRequestの具象クラス

### Servant(召使い)
- Clientからの処理の呼び出しをSchedulerから委譲され、実際に処理を実行する
- ActiveObjectがClientに対して提供しているAPIを実装している
- 単一のスレッドから呼び出される

### ActivationQueue(活性化キュー)
- MethodRequestを保持するキュー
- ClientがSchedulerを通じてエンキューし、Schedulerがデキューする
  (Producer-Consumer)

### VirtualResult(仮想的な結果)
- Future / RealResultと共にFutureパターンを構成する要素
- Clientからの呼び出しに対してFutureが返す仮想的な値

### Future(先物)
- VirtualResult / RealResultと共にFutureパターンを構成する要素

### RealResult(実際の結果)
- VirtualResult / Futureと共にFutureパターンを構成する要素
- Clientからの呼び出しに対してFutureが返す実際の値

## 関連するパターン
- Producer-Consumer
- Future
- Worker Thread
- Thread-Specific Storage
