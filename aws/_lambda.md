# Lambda
- AWSの基盤上でイベント発生時にバックエンドアプリケーションプログラムを実行できるサービス
- ユーザーはEC2のように占有されたインスタンスを持たず、
  アプリケーションプログラムよりも低レイヤーをAWSに委任する
- 起動回数と実行時間によって課金される
- 予めLambdaが対応しているイベントのみ扱うことが可能
  - HTTPリクエスト
  - SQSキューへのエンキュー
  - CloudWatch Eventによるスケジュール実行・定期実行

## 動作フロー
1. ユーザーが実行したいプログラムのコードを事前にLambdaに登録しておく
2. ユーザーがプログラムを実行したいとき、そのプログラムを実行(invoke)するコマンドをLambda に送信する
3. Lambdaがinvokeリクエストを受け取り、プログラムの実行を開始する
4. Lambdaが実行結果をクライアントやその他の計算機に返す

## 参照
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
- [11. Serverless architecture](https://tomomano.github.io/learn-aws-by-coding/#sec_serverless)
- [AWS Lambda](https://aws.amazon.com/jp/lambda/)
