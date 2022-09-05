# DNSパケットフォーマット
- ヘッダ (パラメータ) + 問い合わせ部 (ドメイン名やタイプ)
- 応答時に各セクションに結果を格納して返す

#### ヘッダ
- DNS識別子
  - DNSクエリに対するレスポンスを対応づける識別子
- QR (Query / Response)
  - パケットがDNSクエリかレスポンスかを示す
- オプコード
  - メッセージに含まれるクエリのタイプ
- AA (Authoritative Answer)
  - (レスポンス) ドメインに権威あるネームサーバーからのレスポンスであることを示す
- TC (truncation)
  - レスポンスが長すぎてパケット内に収まらないため切り詰められたことを示す
- RD (Recursion Desired)
  - (DNSクエリ) DNSクライアントは目的のネームサーバーに対して要求した情報がない場合、
    再帰クエリを要求することを示す
- RA (Recursion Available)
  - (レスポンス) ネームサーバーが再帰クエリをサポートしていることを示す
- Z (Reserved)
  - すべて0 (RCodeの拡張に使用される場合もある)
- RCode (Response Code)
  - DNSレスポンスで使われ、エラーの有無を示す
- Question Count
  - Questionセクションに含まれているエントリ数
- Answer Count
  - Answerセクションに含まれているエントリ数
- Name server (Authority) Record Count
  - Authorityセクションに含まれているネームサーバーのリソースレコード数
- Additional Records Count
  - Additional Informationセクションに含まれているその他のリソースレコード数

#### Question
- Questionセクション
  - DNSサーバーに送信された一つ以上のクエリを含む可変長セクション

#### Answer
- Answerセクション
  - クエリのレスポンスとなる一つ以上のリソースレコードを含む可変長セクション

#### Authority
- Authorityセクション
  - 名前解決処理を継続する際に使用できる権威あるネームサーバーを示すリソースレコードを含む可変長セクション

#### Additional
- Additional Informationセクション
  - 必須ではない関連情報を保持するリソースレコードを含む可変長セクション

## 参照
- DNSをはじめよう ～基礎からトラブルシューティングまで～ 改訂第2版
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 3.4
- Real World HTTP 第2版
- 実践パケット解析 第3版
