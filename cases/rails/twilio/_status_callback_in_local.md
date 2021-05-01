# 開発環境でTwilioのStatus Callbackを動作させたい
## 課題
- 動作確認時、コールバックが動作していない

## 前提
- TwilioVideoへ設定するコールバックURLは環境変数`DOMAIN_NAME`を基に生成
- ngrokで開発環境用のURLを生成し、環境変数`DOMAIN_NAME`に設定
- 事前にモックを使用したRequest specを記述しており、通っている

## 実際のインプット
- [twilio-ruby/lib/twilio-ruby/rest/video/v1/room.rb:L59](https://github.com/twilio/twilio-ruby/blob/bee4e7e32686ffaff8d1a43a66b3e3ef2c4820ae/lib/twilio-ruby/rest/video/v1/room.rb#L59)を参照
- `Twilio::REST::Video::V1::RoomList#create`に
  引数`status_callback` / `status_callback_method`を渡している

## 期待するアウトプット
- コールバック時に呼ばれるはずの`Controller#Action`が呼ばれ、処理が実行される

## 実際のアウトプット
- コールバック時に呼ばれるはずの`Controller#Action`が呼ばれていない

## 問題解決の経緯
1. ngrokで生成したURLにアクセスが可能であることを確認
2. インプットにtypoがないか確認
3. アウトプットとしてコールバック時に呼ばれるはずの`Controller#Action`が呼ばれていないことを確認
4. コンソールから`Twilio::REST::Video::V1::RoomList#create`を手動で呼び、返り値を確認
   -> 返り値である`Twilio.Video.V1.RoomInstance`の属性`status_callback`に別のドメインが指定されていることを発見
5. `.env`に`DOMAIN_NAME`が二重に記述されていることを発見
   -> ngrokで生成したドメインでない方が呼ばれていた
6. `.env`から不要な記述を削除し、コンソールを開き直す -> 改善しない
7. `$ spring stop`を実行
8. コールバック時に呼ばれるはずの`Controller#Action`が呼ばれ、処理が実行された
