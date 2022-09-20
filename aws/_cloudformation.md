# CloudFormation
- テンプレートを使いAWSの静的リソースのモデル化と管理を行うプロビジョニングツール
- AWSのインフラ(構成情報)をJSONベースのDSLでを記述する
  - 構成情報 - 作成するリソースの要件
    - e.g. EC2のインスタンスをどれくらいのスペックで何個起動するか、
    インスタンス間はどのようなネットワークで結びどのようなアクセス権限を付与するかなど
- Designer - DSLを記述するためのAWS Management ConsoleのGUIツール
- AWS CDK - CloudFormationをバックエンドとして利用する開発キット
  - プログラミング言語を使用してCloudFormation を自動的に生成する

## 参照
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
- [3. AWS入門](https://tomomano.github.io/learn-aws-by-coding/#sec_aws_general_introduction)
