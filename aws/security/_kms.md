# AWS Key Management Service
- データを暗号化するための鍵を管理するサービス
- EBS、RDS、S3などのサービスで保存されているデータを暗号化できる

#### Customer Data Key (CDK)
- KMSがデータを暗号化する際に利用する鍵
- AWSが暗号化して管理しており、データを読み書きするたびに暗号化・復号する

#### Customer Master Key (CMK)
- KMSがCDKを暗号化する際に利用する鍵
- KMSの機能を利用して作成できる
- AWSが管理するHardware Security Module (HSM) に保存された鍵を利用して暗号化された状態で保存される

## 暗号化方式
#### Client-Side Encryption (CSE)
- アプリケーションの中で暗号化の処理を記述し、データそのものを暗号化する
- CSEで暗号化されたデータは復号鍵がない限り復号できない

#### Server-Side Encryption (SSE)
- EBS、RDS、S3などKMSと統合されたサービスでデータを保存する際、AWSが自動的にKMSの鍵を使って暗号化する
- EBS、RDS、S3などKMSと統合されたサービスからデータを取得する際、AWSが自動的にKMSの鍵を使って復号する

## 参照
- AWSの基本・仕組み・重要用語が全部わかる教科書 20-06
