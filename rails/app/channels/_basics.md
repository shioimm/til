# ActionCable
- Railsが標準で提供する、WebSocketを使用したリアルタイム通信機構

### 用語
- channel: ActionCableにおけるcontroller
- consumer: クライアント・複数のchannelを購読できる
- subscriber: channelを購読しているconsumer
- subscription: channelとsubscriber間の接続
- broadcast: channelからsubscriberに対して直接送信されるpub/subリンク

## サーバーコンポーネント
### Connection
- `app/channels/application_cable/connection.rb`
- Websocketプロトコルの抽象化クラス
- サーバーでWebSocketを受け付けると、`ApplicationCable::Connection`がインスタンス化される

### Channel
- `app/channels/application_cable/channel.rb`
  - Connection を介してメッセージを交換するchannelの抽象クラス
- `app/channels/xxx_channel.rb`
  - `ApplicationCable::Channel`クラスを継承し、論理的な作業単位を記述する
  - consumerがchannelの購読者になると`XxxChannel#subscribed`が呼ばれる
  - consumerから`XxxChannel`クラスに記述されているメソッド`yyy`を呼ぶことができる
    - `this.perform('yyy', {...})`
  - consumerから`XxxChannel`クラスに記述されているメソッド`yyy`を呼ばれたとき、
    channelは所定の処理を行い、`ActionCable.server.broadcast`を使ってsubscriberへ通知を行う

## クライアントコンポーネント
- クライアントが`createConsumer()`を呼ぶとconsumerが作成される
- consumerが購読したいチャンネルに対して`subscription.create`すると、
  consumerはそのチャンネルに対するsubscriberになる
- subscriberはサーバーから通知(とデータ)を受け取ることができ、
  通知に基づいて任意の処理を行うことができる

## 関連ファイル
### `app/javascript`
- `/channels/consumer.js` - ActionCable用のJavaScriptファイルの起点となるファイル
- `/channels/index.js` - ActionCable用のJavaScriptファイルを読み込むファイル
- `/channels/xxx_channel.js` - クライアントサイド用のファイル

### `/channels`
- `/application_cable/channel.rb` - 全てのチャネルのsuperclass
- `/application_cable/connection.rb` - WebSocket接続の認証を行うクラス
- `xxx_channel.rb` - サーバーサイド用のファイル(controllerのような役割)

### `config`
- `cable.yml` - ActionCableのアダプタ設定
- `routes.rb`

## 参照
- [Action Cable の概要](https://railsguides.jp/action_cable_overview.html)
- パーフェクトRuby on Rails[増補改訂版] P260-276
