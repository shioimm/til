# リソースレコード
- ドメイン名に関連付けられているリソースの情報
- ドメイン名のノードに対応する

```
OWNER TTL CLASS TYPE RDATA
```

- OWNER - リソースレコードが置かれている場所のドメイン名
- TTL   - フルリゾルバがリソースレコードをキャッシュできる有効期間
- CLASS - プロトコルファミリ (IN = インターネット)
- TYPE  - リソースレコードタイプ
- RDATA - リソースレコードのデータ

### e.g.
#### リソースレコードの設定

```
// ns1.example.net. (example.com.の権威サーバ) の設定

example.com.     IN    SOA    ns1.example.net. admin.example.com. (
                              2024110901  ; シリアル番号
                              7200        ; リフレッシュ間隔
                              3600        ; リトライ間隔
                              1209600     ; 有効期限
                              86400       ; 最小TTL
                              )

example.com.     IN    NS    ns1.example.net. // 自分自身 (NSレコードの問い合わせの回答のため)
example.com.     IN    NS    ns2.example.net. // 冗長化

example.com.     IN    A     192.0.2.1        // Aレコード
www.example.com. IN    CNAME example.com.     // www.example.com.の問い合わせに対してexample.com.を返す

example.com.     IN    MX    10 mail.example.com. // MXレコード
example.com.     IN    TXT   "v=spf1 include:_spf.example.net ~all" // ドメイン所有権の証明など

```

#### リソースレコードのリクエスト

```
// Question (リクエスト: ドメイン名jprs.jpのAレコードを要求)
jprs.jp       IN  A
```

#### リソースレコードのレスポンス

```
// Answer (レスポンス: ドメイン名jprs.jpのAレコードを回答)
jprs.jp  300  IN  A  117.***.***.***
```

#### リソースレコードセット (RRset)
- 同じドメイン名に対して設定された同じクラス・タイプの複数のリソースレコードのまとまり

#### ゾーンファイル
- 当該ゾーンのリソースレコードの内容をまとめたもの

## リソースレコードの種類
### SOAリソースレコード
- ゾーン管理に関する基本的な情報が記述されたレコード
- ゾーン頂点 (委任により分割されたゾーンの境目の頂点おtなるドメイン名) に対して設定される
  - MNAME - ソーンデータのオリジナルの権威サーバーのドメイン名
  - RNAME - このゾーンの責任者のメールアドレス
  - SERIAL - ソーンのオリジナルコピーの符号なし32ビットバージョン番号
  - REFRESH - セカンダリサーバーがプライマリサーバーへ更新を確認する間隔
  - RETRY - セカンダリサーバーが更新に失敗した後に再施行する間隔
  - EXPIRE - セカンダリサーバーが更新できないときにデータを期限切れにするまでの上限値
  - MINIMUM - ネガティブキャッシュのTTL

### NS (Name Server) リソースレコード
- 委任に関する情報が記述されたレコード
- 委任関係を表すため、ゾーンカットの親側のドメインと子側のドメイン双方に対して設定される
  - NSDNAME - OWNERをゾーンの頂点とするゾーンの権威サーバーのドメイン名

### A / AAAA (Address) リソースレコード
- ドメイン名に対応するIPアドレスが記述されたレコード
  - ADDRESS - IPv4アドレス / IPv6アドレス

### CNAME (Canonical NAME) リソースレコード
- ドメインに対応する正式名 (別名を定義する際に利用) が記述されたレコード
  - e.g. 当該ドメイン名から、そのドメインを持つサービスが利用しているCDNのドメイン名を引く場合などに利用
- OWNERに別名を記述する
  - CANONICALNAME - 正式名

### PTR (Pointer) リソースレコード
- IPアドレスに対するドメイン名が記述されたレコード
  - PTRDNAME - IPアドレスに対するドメイン名

### MX (Mail Exchange) リソースレコード
- ドメイン名に対応するメール配送情報が記述されたレコード
  OWNERにメールを受け取るメールアドレスのドメイン名を記述
  - PREFERENCE - 優先度を示す数値
  - EXCHANGE - メールの配送先のメールサーバーのドメイン名

### TXT (Text) リソースレコード
- 任意の文字列が記述されたレコード↲
  - TXT-DATA - 1つ以上の文字

### SRV (Service) リソースレコード
- 当該ドメインで提供されているサービスの詳細な情報が記述されたレコード
  - サービスの種別
  - プロトコル (TCP / UDP)
  - サービスが稼働するドメイン名
  - TTL
  - 優先度 (昇順)
  - 重み (同じ優先度の中でのアクセスの割合)
  - サービスが稼働するポート番号
  - 正確に特定可能なホスト名

### HTTPSリソースレコード
- HTTPSサービスの提供に関する情報が記述されたレコード
- 従来WebサーバをDNSに登録するためにIPアドレスをA / AAAAレコードとして登録していた運用を置き換える
- WebブラウザがWebサイトにアクセスする際に問い合わせる際に利用される

```
;; HTTPSリソースレコードを利用しない
    example.com.  IN  A         ***.***.***.***
                  IN  AAAA      ***:***:***:***

;; HTTPSリソースレコードを利用する
    example.com.  IN  HTTPS  1  svr.example.com.
svr.example.com.  IN  A         ***.***.***.***
                  IN  AAAA      ***:***:***:***

;; HTTPSリソースレコードとA / AAAAレコードを併用する
    example.com.  IN  HTTPS  1  .
    example.com.  IN  A         ***.***.***.***
                  IN  AAAA      ***:***:***:***
```

## 参照
- Software Design 2022年8月号
- [“HTTPSレコード”って知ってる？今知るべき4つの注意点](https://eng-blog.iij.ad.jp/archives/12882)
