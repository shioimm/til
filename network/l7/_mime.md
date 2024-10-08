# MIME
- Multiple Internet Mail Extensions
- データ形式をインターネット (電子メール、WWW、NetNews) で幅広く使えるように拡張するプロトコル
- OSI参照モデルにおいてはプレゼンテーション層に該当する

#### 基本構成
- MIMEヘッダ + 空行 + 本文

```
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="MSG_boundary"

message
--MSG_boundary
Content-Type: text/plain; charset=US-ASCII

message

--MSG_boundary
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64

**********************************

--MSG_boundary--
```

#### 複数コンテンツの指定
- アプリケーションヘッダのContent-Typeに`Multipart/Mixed`を指定し、
  `boundary=`オプションに区切り文字を指定する
- 空行 + `--区切り文字`で仕切った各区間に指定したいMIMEヘッダと本文を置く

#### 拡張子との対応
- サーバーにリクエストして得られるファイルは拡張子に対応するMIMEタイプが
  サーバー上のマッピングファイル`/etc/mime.types`で指定されている
- コードで生成した場合は明示的に示す必要がある

## S/MIME (Secure MIME)
- MIMEに秘匿性と完全性を提供する規格
  - 秘匿性のために公開鍵暗号が利用される (相手の公開鍵を取得しておく必要がある)
  - 完全性や否認防止のために署名が利用される
- 署名がついたメールには本文に加えて添付ファイルsmime.p7sが付与される
- S/MIMEで送信されたメールはS/MIMEに対応するメールクライアントでなければ閲覧できない

## 参照
- マスタリングTCP/IP 入門編
- Web配信の技術
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
