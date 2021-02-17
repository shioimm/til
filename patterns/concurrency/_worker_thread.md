# Worker Thread(Thread Pool)
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第8章

## TL;DR
- Client側がChannelを通じてWorker側にリクエストを送信する
  Worker側がChannelを通じてClient側からリクエストを受信し処理を行う
  - Worker側にはリクエストを処理するために予め決まった数のスレッドが生成されている
  - Workerが一つずつ処理を取りに行き、処理を行う
- 処理の生成と実行を分離する
  - 応答性が向上する
  - 実行順序を制御することができる
  - キャンセル・繰り返し実行が可能
  - 分散処理を実現できる
- ChannelがGuarded Suspensionを使用する

## ガード条件
- (Workerに対して)ClientがChannelにアクセスしようとしていないかどうか
- (Clientに対して)WorkerがChannelにアクセスしようとしていないかどうか

## 要素
### Client
- Requestを作成し、Channelに渡す

### Channel
- ClientからRequestを受け取り、Workerに渡す

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
- Produer-Consumer
- Thread-Per-Message
- Command
- Future
- Flyweight
- Thread-Specific Storage
- Active Object
