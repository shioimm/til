# AWS Secrets Manager
- データベースのパスワードやAPIキーなどの認証情報 (シークレット) を集約し、一元管理するサービス
- アプリケーションはSecrets Managerにアクセスすることでシークレットを取得できる
- KMSで暗号化して保存できる

#### シークレットの自動ローテーション機能
- Secrets Managerはシークレットの更新間隔を指定することによって自動でパスワード更新を行う

## 参照
- AWSの基本・仕組み・重要用語が全部わかる教科書 20-07
