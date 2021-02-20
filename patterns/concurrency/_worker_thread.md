# Worker Thread(Thread Pool)
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第8章

## TL;DR
- ClientがChannelを通じてWorkerスレッドにRequestを送信する
  WorkerスレッドがChannelを通じてClientからRequestを受信し処理を行う
  - ChannelにはRequestを処理するために予め決まった数のWorkerスレッドが生成されている
  - Workerスレッドが一つずつRequestを取りに行き、Requestを実行する

### 文脈
- ClientがHostに対して処理を呼び出しているとき

### 問題
- Hostの処理が終わるまで制御がClientに戻らない
- 処理に時間がかかると応答性が下がる
- Thread-Per-Messageを使用するとスレッド生成時間の分スループットが下がる
  スレッドの生成数に応じてキャパシティが低下する

### 解決方法
- 処理を実行するスレッド(Worker)をあらかじめ生成しておく
- 処理の依頼を表す情報をWorkerに渡すと、Workerが実際の処理を実行する
- ClientはHostに対して処理を呼び出した後、
  Workerの処理の実行を待たずに自身の処理に戻る

### 処理の依頼と実行の分離
- 依頼(Client)を行う役と実行を行う役(Worker)を分離する
  - 応答性が向上する
  - 実行順序を制御することができる
  - キャンセル・繰り返し実行が可能
  - 分散処理を実現できる

## 要素
### Client
- Requestを作成し、Channelに渡す
- RequestをChannelに渡すためにProducer-Consumerを使用する

### Channel
- ClientからRequestを受け取り、Workerに渡す
- ClientからRequestを受け取る際およびWorkerがRequestを処理する際に
  Guarded Suspensionを使用する
  - ガード条件1: (Workerに対して)ClientがChannelにアクセスしようとしていないかどうか
  - ガード条件2: (Clientに対して)WorkerがChannelにアクセスしようとしていないかどうか

### Worker
- ChannelからRequestを受け取り、処理を実行する
- 処理が終わったらChannelへ次のRequestを受け取りに行く

### Request
- 処理
- 処理に必要な情報を保持している

## パフォーマンス
- あらかじめ決まった数のWorkerが生成されており、
  処理のたびにスレッドを生成する必要がない
  - スレッドを使い回しリサイクルするため
    Thread-Per-Messageよりもスループットが向上する
  - 処理の量に応じでWorkerの数を増減させることで
    キャパシティを制御することができる

## 関連するパターン
- Thread-Per-Message
  - Clientから依頼される側によるスレッド生成のコストを気にしない場合
- Future
  - 処理の返り値が必要な場合
- Command
- Flyweight
- Thread-Specific Storage
- Active Object
