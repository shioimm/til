# AWS Fargate
- サーバーレスなコンテナ実行環境
‐ コンテナイメージを指定するだけでコンテナを実行できる
  - コンテナ起動時にはコンテナレジストリサービスからイメージがダウンロードされる
- クラスタ管理が不要
- ECS・EKSのオプション機能の一つとして提供される
- Fargateを使ってコンテナを起動する際はコンテナが使用するリソース(仮想CPUユニット数・メモリ容量)を指定する
  - 利用料金はリソースの使用量と仕様時間をベースに計算される

## AWS Lambdaとの違い
#### Lambda
- 実行したいプログラムのソースコードを起動時に指定する
- 実行時間の上限が15分
- デプロイパッケージサイズの上限が250MB

#### Fargate
- 実行したいコンテナのイメージを起動時に指定する

## 参照
- 仮想化&コンテナがこれ1冊でしっかりわかる教科書
