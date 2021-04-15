# Elastic Load Balancing
- 参照: [Elastic Load Balancing](https://aws.amazon.com/jp/elasticloadbalancing/)
- 参照: AWSをはじめよう　～AWSによる環境構築を1から10まで～

## TL;DR
- ロードバランサ
  - ALB(Application Load Balancer) - リクエストレベル(HTTP / HTTPS)
  - NLB(Network Load Balancer) - 接続レベル(TCP / UDP)
- 冗長化やパフォーマンスの調整を行う

## Get Started
1. EC2ダッシュボード
  -> ロードバランサー
  -> ロードバランサーの作成(-> 種類の選択)
2. ロードバランサーの設定
    - 全てのAZにチェック
3. セキュリティ設定の構成 -> セキュリティグループの設定
4. ルーティングの設定
    - ターゲットグループ - ロードバランサーの分散先となるサーバーのグループ
5. ターゲットの登録
    - インスタンスの選択 -> 登録済みに追加
6. 確認
7. ヘルスチェック
    - EC2ダッシュボード
    -> ターゲットグループ
    -> ターゲット
    -> ステータス
8. Route53でElasticIPを直接指定している箇所を修正
    - Alias - Alias Targetにロードバランサーを指定
