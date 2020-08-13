# ActionCable
- 参照: [Action Cable の概要](https://railsguides.jp/action_cable_overview.html)
- 参照・引用: パーフェクトRuby on Rails[増補改訂版] P260-276

## TL;DR
- Railsが標準で提供する、WebSocketを使用したリアルタイム通信機構
- デフォルトで`/cable`にActionCable用のRackサーバーがマウントされており、
  WebSocket通信時にアクセスする

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

## Usage
```
# クライアント用のxxx_channel.jsとサーバーサイド用のxxx_channel.rbが生成される
$ rails g channel xxx(チャネル名) yyy(アクション名)
```

```ruby
# app/channels/xxx_channel.rb
# クライアントはWebSocket通信を通じてチャネルと関連づけられる(購読)
# クライアントは複数のチャネルを購読できる

class XxxChannel < ApplicationCable::Channel
  def subscribed # 購読後に呼ばれる
    # ブロードキャスト用のストリーム名some_channelを設定
    stream_from "some_channel"
  end

  def unsubscribed # 購読解除後に呼ばれる
  end

  def yyy(data) # クライアントから呼び出された時に実行される
    # ストリーム名some_channelで通信している全てのクライアントへメッセージを送信
    ActionCable.server.broadcast("some_channel", { message: data['message'] })
  end
end
```

```js
# サーバーサイドのチャネルを購読するための処理

import consumer from "./consumer"

consumer.subscriptions.create("XxxChannel", {
  connected() { // 接続時のコールバック
    // Ex.
    document.querySelector('input[入力内容を取得するための識別子]')
            .addEventListener('keypress', (event) => {
              if (evemt.key === 'Enter') {
                this.yyy(event.targte.value)
                event.target.value = ''
                return event.preventDefault()
              }
            })
  },

  disconnected() { // 切断時のコールバック
  },

  received(data) { // サーバーからデータを受信した時のコールバック
    // Ex.
    alert(data['message'])
  },

  yyy: function(message) { // サーバーサイドのyyyアクションをWebSocket経由で呼び出す
    // Ex. サーバーサイドへメッセージを送信
    return this.perform('yyy', { message: message });
  }
});

// 1. connected() -> yyy()
// 2. サーバーサイドへメッセージが送信される
// 3. メッセージがサーバーサイドからブロードキャストされる
// 4. クライアントがメッセージを受信 -> received()
```

```yml
# config/cable.yml
# アダプタの設定を行う

development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: action_cable_sample_production
```

```ruby
# cable/config.ru
# WebSocket用のスタンドアロンなサーバープロセスを立ち上げる場合

require_relative '../config/environment'

Rails.application.eager_load!

run ActionCable.server

# $ bundle exec puma cable/config.ru
```

```ruby
# config/environments/xxx.rbで

Rails.application.configure do
  # デフォルトでWeb用のサーバーにActionCableがマウントされているため、
  # WebSocket用のスタンドアロンなサーバープロセスを立ち上げる場合は
  # 明示的に解除しておく(nil)
  config.action_cable.mount_path = nil

  # ActionCableへの接続先を設定する(デフォルトではlocalhost)
  config.action_cable.url = 'wss://example.com/cable'
  # app/views/layouts/application.html.erbのhead内で<%= action_cable_meta_tag %>を読み込んでおく

  # ActionCableへの接続先を設定する場合、接続可能なオリジンを指定しておく
  config.action_cable.allowed_request_origins = [
    'http://example.com', /http:\/\/example.*/
  ]

  # WebSocket経由で受け取ったメッセージを処理するワーカースレッド数の設定
  # (デフォルトでは一プロセスにつき4スレッド)
  config.action_cable.worker_pool_size = 10
  # config/database.ymlのpoolの数値も変更しておく
  # WebSocket用のスタンドアロンなサーバープロセスを立ち上げていない場合
  # ActionCableのスレッド数とWeb用のスレッド数を合わせた数にする
end
```
