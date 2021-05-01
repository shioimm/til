# AWSコンテナ
- AWSの複数のサービスを組み合わせてコンテナを実行する場所として使用する

### どのサービスを選択するか
- コンテナ実行環境の選択
  サーバーを自分で管理するかどうか
 - Yes -> Amazon EC2  - 仮想マシンインフラストラクチャ上でコンテナを実行
 - No  -> AWS Fargate - サーバーレスでコンテナを実行
- コンテナオーケストレーターの選択
  Kubernetesを使用するかどうか
  - Yes -> EKS - Kubernetesを使用してコンテナを管理する
  - No  -> ECS - AWSによるコンテナオーケストレーション
- コンテナレジストリ
  - ECR - コンテナイメージの保存、管理、デプロイ

## 参照
- [AWS のコンテナ](https://aws.amazon.com/jp/containers/)
- [Containers on AWS](https://aws.amazon.com/jp/containers/services/)
