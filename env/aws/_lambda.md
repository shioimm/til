# Lambda
- AWSの基盤上でイベント発生時にバックエンドアプリケーションプログラムを実行できるサービス
- アプリケーションプログラムよりも低レイヤーをAWSに委任する
- 起動回数と実行時間によって課金される
- 予めLambdaが対応しているイベントのみ扱うことが可能
  - HTTPリクエスト
  - SQSキューへのエンキュー
  - CloudWatch Eventによるスケジュール実行・定期実行

## 参照
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
