# AWS Serverless Application Model
- サーバーレスアプリケーションを稼働させるための基盤構築と
  アプリケーションのデプロイを自動化するためのサービス
- サーバーレスアプリケーション向けのCloudFormationの拡張機能機能
- JSONやYAMLで記述されたテンプレートからリソースをデプロイする

| Type                          | デプロイされるリソース                                   |
| -                             | -                                                        |
| AWS::Serverless::Function     | Lambda (Lambda関数)                                      |
| AWS::Serverless::LayerVersion | Lambda (Lambda Layers)                                   |
| AWS::Serverless::API          | API Gateway (REST API)                                   |
| AWS::Serverless::HttpAPI      | API Gateway (HTTP API)                                   |
| AWS::Serverless::SimpleTable  | DynamoDB (テーブル)                                      |
| AWS::Serverless::Application  | Serverless Application Repogitory (公開アプリケーション) |
| AWS::Serverless::StateMachine | Step Functions (ステートマシン)                          |

- SAM CLIを利用してアプリケーションの構築を行う

## 参照
- AWSの基本・仕組み・重要用語が全部わかる教科書 13-06
