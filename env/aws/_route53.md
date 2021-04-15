# Route53
- 参照: DNSをはじめよう ～基礎からトラブルシューティングまで～ 改訂第2版

## TL;DR
- DNSサービス
- ドメイン登録、DNSルーティング、リソースの正常性チェックを任意の組み合わせで実行することができる
- 信頼性・コスト・柔軟性に優れる

## Get Started
### ホストゾーンの作成
1. Create Hosted Zone
    - Name - ドメイン名
    - Type - Public Hosted Zone
2. NSレコード(ドメイン名のネームサーバー)とSOAレコード(管理情報)が作成される

### レコードセットの作成
1. Hosted Zone -> ドメイン名
2. Create Record Set
    - Name  - ホスト名
      Value - Elastic IP
3. ホスト名 + ドメイン名のAレコードが作成される
