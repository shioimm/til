# AWS CodeCommit
- Gitベースのソースコードリポジトリサービス

#### CodeCommitと連携できるAWSサービス
- CloudFormation - CodeCommitのリポジトリを含むリソースをテンプレートに記述し、作成できる
- CloudTrail - CodeCommitに対して実行されたAPIコールやGitコマンドのイベントを記録し、ログに保存する
- CloudWatch Event - リポジトリをモニタリングし、イベント発生時にSQS、Kinesis、Lambdaなどで処理を実行する
- CodeGuru Reviewer - CodeCommitに紐づけたリポジトリのソースコードの分析・コードレビューを行う
- AWS KMS - リポジトリの暗号化を行う
- AWS Lambda - リポジトリに発生したイベントをトリガーとしてLambda関数を実行できる
- Amazon SNS - リポジトリに発生したイベントに対してトリガーを作成し、通知する

## 参照
- AWSの基本・仕組み・重要用語が全部わかる教科書 14-03
