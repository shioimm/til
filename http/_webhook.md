# Webhook(Webコールバック、HTTPプッシュAPI)
- ユーザー定義のHTTPコールバック
- 何らかのイベントにトリガーし、アプリケーションの動作を拡張、変更する仕組み
- 別のアプリケーションやサードパーティーのAPIとの統合を容易にする
  - Ex. CIにおけるアプリケーションのビルド、バグ追跡システムへの通知、プラウザプッシュ通知

## 仕組み
- Webhookプロバイダ(送信側)から提供されるAPI仕様に従い、開発者は受信側のAPIを実装する
- 送信側は受信側に対してHTTPリクエストを行い、受信側はその内容をパースして利用する
  - リクエストはPOSTメソッドで処理される
  - フォーマットは通常JSONを使用する
- HTTPリクエストを受信して返信できるプラッットフォームであればサーバーレスフレームワークでも使用可能

## 参照
- [Webhook](https://en.wikipedia.org/wiki/Webhook)
- [Webhookとは？](https://sendgrid.kke.co.jp/blog/?p=1851)
- [Webhook](https://jp.twilio.com/docs/glossary/what-is-a-webhook)
