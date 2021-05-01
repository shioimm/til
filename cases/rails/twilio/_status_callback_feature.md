# Status Callbackを使用したイベント通知
- [Status Callbacks](https://www.twilio.com/docs/video/api/status-callbacks)
- [twilio-ruby/lib/twilio-ruby/rest/video/v1/room.rb:L59](https://github.com/twilio/twilio-ruby/blob/bee4e7e32686ffaff8d1a43a66b3e3ef2c4820ae/lib/twilio-ruby/rest/video/v1/room.rb#L59)

## 課題
- TwilioVideoのルームから参加者が退室した際にアプリケーションに通知を送り、
  所定の処理を行いたい

## 設計
| Verb | URL             | Controller                 | Action  |
| -    | -               | -                          | -       |
| POST | /twilio/webhook | Twilio::WebhooksController | #create |

- StatusCallbackはRoomの属性
- StatusCallback自体は今後も使用する機会がありそうなので汎用性の高いAPIを作りたい
- 具体的に何をやるのかは発生したイベントによって異なる
- 今回の処理には副作用が含まれる
- イベントによってサービスクラスを呼び出すようにする(`case`文)
  - デフォルトでは`head :accepted`を返すようにする

## 実装
### ルームの生成
- `Twilio::REST::Video`インスタンス生成時にコールバックURLを設定する
```ruby
TWILIO_CLIENT = Twilio::REST::Client.new(account_sid, auth_token)

Twilio::REST::Video.new(TWILIO_CLIENT).rooms.create(
  status_callback: "https//:#{ENV['DOMAIN_NAME']}/twilio/webhook",
  status_callback_method: POST
)
```

### コールバックの実装
```ruby
module Twilio
  class WebhooksController
    def create
      case params['StatusCallbackEvent']
      when 'participant-disconnected' # 参加者が退室した時
        # サービスを呼び出す
      else
        head :accepted
      end
    end
  end
end
```
