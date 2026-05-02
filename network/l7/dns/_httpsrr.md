# HTTPSリソースレコード (HTTPS Resource Record / HTTPS RR)
- エンドツーエンドで通信を行う際の後続のプロトコルに関する情報提供を行うリソースレコード
  - HTTPSレコードはHTTP/HTTPS通信に特化したもの
  - SVCBレコードは任意のプロトコルで利用できるもの
- 従来WebサーバをDNSに登録するためにIPアドレスをA / AAAAレコードとして登録していた運用を置き換える
- WebブラウザがWebサイトにアクセスする際に問い合わせる際に利用される

```text
<owner name>  IN HTTPS  <priority>  <TargetName>  <params>
```

```text
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

#### AliasMode
- 別のDNS名への代替を行うもの
  - CNAMEレコードとの違いはZone Apex (DNSゾーンの最上位のドメイン名) の応答が可能になる点
- priorityは0
- レコード内にリダイレクトさせたいドメイン名を記述する

#### ServiceMode
- 対象になるドメインで利用する情報を事前に提供するもの
- 接続先の対応プロトコル情報の取得、TLSの公開鍵の取得、ポート番号の指定を行うなどを可能にする
- priorityは1以上
- レコード内に必要な情報を記述する
- priorityの小さい順に処理される

## 参照
- [“HTTPSレコード”って知ってる？今知るべき4つの注意点](https://eng-blog.iij.ad.jp/archives/12882)
- [Amazon Route 53の新しいHTTPS/SVCB/SSHFP/TLSAリソースレコードタイプについての技術概説とユースケースの考察](https://business.ntt-east.co.jp/content/cloudsolution/ih_column-154.html#section-2)
