# DNSパケットフォーマット
- ヘッダ (パラメータ) + 問い合わせ部 (ドメイン名やタイプ)
- 応答時に各セクションに結果を格納して返す

#### Headerセクション (制御情報)
- ID
  - 当該DNSメッセージのID
  - 値は問い合わせ側で生成され、応答側は問い合わせメッセージのIDフィールドの値をコピーする
- QR (Query / Response)
  - パケットがクエリ (0) かレスポンス (1) かを示す
- Opcode
  - メッセージに含まれるクエリのタイプ
- AA (Authoritative Answer)
  - (レスポンス) 応答したサーバが問い合わせのドメイン名の情報に対する権限を持っている (1) かどうかを示すフラグ
- TC (TrunCation)
  - レスポンスが長すぎてパケット内に収まらないため切り詰められたことを示すフラグ
- RD (Recursion Desired)
  - (リクエスト) 名前解決を要求するフラグ
  - 権威サーバに対しては0 (非再帰的問い合わせ) 、フルリゾルバに対しては1 (再帰的問い合わせ)
- RA (Recursion Available)
  - (レスポンス) 名前解決が不可能 (0) か可能 (1) か示すフラグ
- Z (Reserved)
  - すべて0 (RCodeの拡張に使用される場合もある)
- AD (Authentic Data)
  - DNSSECで使用されるフラグ
- CD (Checking Disabled)
  - DNSSECで使用されるフラグ
- RCode (Response Code)
  - (レスポンス) レスポンスのステータスを示す
- Question Count
  - Questionセクションに含まれているエントリ数 (通常1)
- Answer Count
  - Answerセクションに含まれているエントリ数
- Name server (Authority) Record Count
  - Authorityセクションに含まれているName server resource record数 (通常1)
- Additional Records Count
  - Additional Informationセクションに含まれているその他のRecource Record数 (通常1)

#### Questionセクション (問い合わせ)
- DNSサーバーに送信された一つ以上のクエリを含む可変長セクション
- QNAME
  - 問い合わせるドメイン名
  - ドメイン名はサブドメインを表すラベルの列として表現する
- QTYPE
  - 問い合わせの種類
- QCLASS
  - リソースレコードのクラスの指定

#### Answerセクション (問い合わせに対する応答)
- Questionセクションに記述された問い合わせに対する回答
- 可変個のリソースレコード (RR) で構成される

#### Authorityセクション (問い合わせに対する応答)
- 問い合わせた先のサーバが当該ドメイン名の権威を持たない (AAフラグがない) 場合、
  そのドメイン名の委任先のDNSサーバを示すNSレコード
- 可変個のリソースレコード (RR) で構成される

#### Additionalセクション (問い合わせに対する応答)
- 付随情報として、Authorityセクションに記述された権威DNS サーバのAレコードやAAAAレコードなど
- 可変個のリソースレコード (RR) で構成される

### RRのフォーマット
- NAME
  - リソースレコードに関連するドメイン名
- TYPE
  - リソースレコードの種類
- CLASS
  - リソースレコードのクラス
- TTL
  - 当該リソースレコードをキャッシュとして保持してもよい秒数
- RDLENGTH
  - RDATAの長さ
- RDATA
  - リソースを表現する可変長のフィールド

## 参照
- DNSをはじめよう ～基礎からトラブルシューティングまで～ 改訂第2版
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 3.4
- Real World HTTP 第2版
- 実践パケット解析 第3版
- プロフェッショナルIPv6 16
