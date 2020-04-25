# ActionCable
- 参照: [Action Cable の概要](https://railsguides.jp/action_cable_overview.html)

### 用語
- connection: クライアントとサーバー間を結ぶ
- channel: ActionCableにおけるコントローラの役割
- consumer: WebSocketコネクションにおけるクライアント・複数のchannelにsubscribeできる
- subscriber: channelにsubscribeされたconsumer
- subscription: channelとconsumer間のコネクション
- broadcast: channelからsubscriberに対して直接送信されるpub/subリンク

### Pub/Subパラダイム
- サーバーと多数のクライアント間の通信を確立するためにActionCableが採用しているパラダイム
- PublisherがSubscriberの抽象クラスに情報を送信する
- Publisherは個別の受信者を指定しない

## ActionCableにおけるサーバーコンポーネント
### Connectionクラス
- サーバーでWebSocketを受け付けると、ApplicationCable::Connectionがインスタンス化される
- connectionオブジェクトはchannel subscriberの親となる
- connectionはidを持つ(`ex. identified_by: current_user`)
  - idはそのconnection以外で作成されるすべてのchannelインスタンスでも共通に利用できる
  - ex. current_userによるコネクションが識別されると、同じユーザーによる他のコネクションを操作できる

### Channelクラス
- ApplicationCable::Channelを継承し、論理的な作業単位を記述する
- consumerがchannelを購読(subscribe)すると`Channel#subscribed`メソッドが呼ばれる

## ActionCableにおけるクライアントコンポーネント
### Connection
- クライアント側で`createConsumer()`を呼ぶことによりconsumerが作成される
- 利用したいsubscriptionを指定することによりconnectionが確立される

### Subscriber
- 指定のchannelにsubscriptionを作成するとconsumerがsubscriberになる

## ActionCableにおけるクライアント-サーバー間のメッセージパッシング
### Stream
- broadcastするコンテンツをどのsubscriberにルーティングするか指定する(`stream_from` `stream_for`)

### BroadCasting
- サーバー側から送信された内容はすべてbroadcastを経由し、
  同じ名前のbroadcastをストリーミングするchannelのsubscriberに直接ルーティングされる

### Subscription
- サーバー側から送信された内容は、connection idに基づきchannel subscriberにルーティングされる

### Params
- クライアントサイドにてsubscriptionを確立する際、
  `subscriptions.create`関数にchannel名を指定するハッシュを渡すことでchannelを特定する
