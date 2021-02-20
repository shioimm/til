# Producer-Consumer
- 参照: Java言語で学ぶデザインパターン入門 マルチスレッド編 第5章

## TL;DR
- ProducerスレッドからConsumerスレッドへChannelを介して安全にデータを渡す
- ChannelがDataを中継する仕事に専念することで、
  ProducerはDataを作成する仕事に専念できる
  ConsumerはDataを利用する仕事に専念できる
- Producer / Consumerが単数の場合、Pipeパターンと呼ぶ

### 文脈
- あるスレッド(Producer)から別のスレッド(Consumer)へデータを渡したいとき

### 問題
- ProducerとConsumerの処理スピードが異なっている場合、
  遅い方の処理がボトルネックになってスループットが下がる
- 各スレッドがリソースに同時にアクセスすると、リソースの安全性が確保されない

### 解決方法
- ProducerとConsumerの間に中継地点となるChannelを用意する
- Channelの中で処理の排他制御を行い安全性を確保する

## 要素
### Data
- Producerによって作成され、Consumerによって利用される

### Producer
- Dataを作成してChannelに渡す

### Consumer
- Channelからデータを受け取って利用する

### Channel
- Producerからデータを受け取り、Consumerからのリクエストに応じてDataを渡す
- ProducerからDataを受け取る際およびConsumerにDataを渡す際に
  Guarded Suspensionを使用する
  - ガード条件1: (Consumerに対して)ProducerがChannelにアクセスしていないかどうか
  - ガード条件2: (Producerに対して)ConsumerがChannelにアクセスしていないかどうか

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
- Command
- Strategy
