# Kerberos認証
- LDAP規格 (情報を一元管理するDB) とSASL認証機能のセットで使用されるSSO機構
- 通常社内ネットワーク内での認証プロトコルとして使用され、クライアントとサーバ間でチケットを用いて認証を行う
  - チケットはKDC (Key Distribution Center) が発行を行う
  - クライアントはKDCから発行されたチケットを使い、各サービスにアクセスする

#### 動作フロー
1. KDCからのアクセストークンとセッションキーを取得する
2. KDCへアクセストークンとセッションキーを送信し、チケットとセッションキーを取得する
3. サービスへチケットとセッションキーを送信することでシングルサインオンが実現する

## 参照
- Real World HTTP 第2版
- マスタリングTCP/IP 情報セキュリティ編
