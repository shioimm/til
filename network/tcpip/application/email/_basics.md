# 電子メール
#### 電子メールの構成要素
- メールアドレス
- データ形式
  - MIME
- 転送プロトコル
  - SMTP - 送信MUAとMTA間、MTAとMTA間で電子メールを配送するプロトコル
  - POP / IMAP - 受信MUAがMTAから電子メールを受け取るプロトコル
- メールクライアント
  - MUA (mail user agent)
- メールサーバー
  - MTA (mail transfer agent)

## 迷惑メール対策の仕組み
#### 送信元ユーザーを認証する仕組み
- POP before SMTP
  - メール送信前にPOPによるユーザー認証を行う
- SMTP認証
  - メール送信時にSMTPサーバーでユーザー認証を行う(SMTPの拡張)

#### 送信元ドメインを認証する仕組み
- SPF(Sender Policy Framework)
  - 送信元メールサーバーのIPアドレスをDNSサーバーに登録しておく
  - 受信したメールのIPアドレスと送信元メールサーバーのIPアドレスを比較検証する
- DKIM(DomainKeys Identified Mail)
  - 送信元メールサーバーで電子署名を付与し、受信側で電子署名を認証する
    - 送信元メールサーバーで署名に利用する公開鍵をDNSサーバーに登録しておき、
      受信側が公開鍵を取得して署名を認証する
- DMARK(Domain bsaed Message Authentication, Reporting and Conformance)
  - SPFやDKIMにおいて、認証が失敗した時のメールの取り扱いについて
    送信者がDNSサーバーに登録して公開する

## 参照
- マスタリングTCP/IP 入門編
