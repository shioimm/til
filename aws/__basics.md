# AWS
#### リージョン
- 地理的ロケーション
- 最低二つ以上のAZで構成される
- データセンターの所在地
- Regionごとに提供されるサービスが異なる

#### Availability Zone (AZ)
- リージョン内で地理的に隔離されたデータセンター
- ひとつのリージョン内でそれぞれが切り離され、冗長的な電力源・ネットワーク・接続機能を持つ
- 他のAZの障害からの分離
  - 可用性を高めるため複数のAZを利用した実装をベストプラクティスとする
- ユーザーが認識する物理的地理的配置の最小単位
- ゾーンによって細かい制約が異なる

## ARN (Amazon Resource Name)
- AWS のリソースを識別するための名前

```
arn:${パーティション}:${サービス名}:${リージョン}:${AWSのアカウントID}:${リソースID}

arn:${パーティション}:${サービス名}:${リージョン}:${AWSのアカウントID}:${リソースタイプ}/${リソースID}

arn:${パーティション}:${サービス名}:${リージョン}:${AWSのアカウントID}:${リソースタイプ}:${リソースID}
```

- パーティション - 複数のリージョンをまとめたグループ
- リソースタイプ、リソースID - リソースに振られたID

## 参照
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
- [3. AWS入門](https://tomomano.github.io/learn-aws-by-coding/#sec_aws_general_introduction)
- AWSの知識地図〜現場必修の基礎から構築・セキュリティまで 2.3
