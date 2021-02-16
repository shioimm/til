# Producer-Consumer
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第5章

## TL;DR
- ProducerスレッドからConsumerスレッドへ安全にデータを渡す
  - Producer - データを作成するスレッド
  - Consumer - データを利用するスレッド
- Producer - Consumer間の同期を取るために橋渡しが必要
  - Producer / Consumerは同期が取れるまで処理を待つ
- Producer / Consumerが単数の場合、Pipeパターンと呼ぶ
- ChannelがGuarded Suspensionを使用する

## 要素
### Data
- Producerによって作成され、Consumerによって利用される

### Producer
- Dataを作成してChannelに渡す

### Consumer
- Channelからデータを受け取って利用する

### Channel
- Producerからデータを受け取り、Consumerからのリクエストに応じてDataを渡す
- 安全性確保のためProducerとConsumerからのアクセスに対して排他制御(Guarded Suspension)を行う
- ChannelがDataを中継する仕事に専念することで、
  ProducerはDataを作成する仕事に専念できる
  ConsumerはDataを利用する仕事に専念できる

## データを渡す順
- キュー(LIFO)
- スタック(FIFO) - Producer-Consumerパターンにおいてあまり使用されない
- 優先順位付きキュー

## 再利用性
- 排他制御をChannelに隠蔽することによって再現性を高める

## パフォーマンス
- Producerが複数、Consumerが単数の場合Channelの排他制御が不要になるため
  コードがシンプルになりパフォーマンスが向上する(イベントディスパッチングスレッド)

## 関連するパターン
- Mediator
- WorkerThread
- Command
- Strategy
