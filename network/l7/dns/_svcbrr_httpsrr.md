# SVCBリソースレコード (SVCB Resource Record / SVCB RR) / HTTPSリソースレコード (HTTPS Resource Record / HTTPS RR)
- エンドツーエンドで通信を行う際の後続のプロトコルに関する情報提供を行うリソースレコード
  - HTTPSレコードはHTTP/HTTPS通信に特化したもの
  - SVCBレコードは任意のプロトコルで利用できるもの

```text
<owner name>  IN [SVCB | HTTPS]  <SvcPriority>  <TargetName>  <SvcParams>
```

- SvcPriority: 優先度 (0 - 65535) (必須)
  - 0: AliasMode
  - 0以外: ServiceMode
- TargetName: owner nameを解決し、実際にアクセスされるホスト名 (必須)
- SvcParams: SvcParamKey=SvcParamValueのペア (オプション)
  - AliasModeでは無視される

```text
;; 利用しない
    example.com.  IN  A         ***.***.***.*** ;; アクセスされるIPアドレスを登録する
                  IN  AAAA      ***:***:***:***

;; HTTPSリソースレコードを利用する
    example.com.  IN  HTTPS  1  svr.example.com. ;; アクセスされるホスト名を登録する
svr.example.com.  IN  A         ***.***.***.***  ;; アクセスされるホストのIPv4アドレス
                  IN  AAAA      ***:***:***:***  ;; アクセスされるホストのIPv6アドレス
```

#### AliasMode
- エイリアスを定義するためのモード
  - SvcPriority: 0
  - TargetName: HTTPSレコードの再問い合わせをさせるホスト名
    - `.`の場合、owner nameがアクセス不可であることを示す
- クライアントはAliasModeのHTTPSレコードを受信した場合、TargetNameに対して再帰的にHTTPSレコードを問い合わせる
- CNAMEレコードとの違いはゾーン頂点に設定できる点

### ServiceMode
- 対象ドメインのサービス提供ホストを提示するモード
  - SvcPriority: 1以上 (小さい方を優先)
  - TargetName: アクセスされるホスト名
  - SvcParams: `ech`、`alpn`、`port`などのパラメータ
    - `.`の場合、owner nameがTargetNameであることを示す
- SVCB-reliant: ECHを利用するため、SVCBレコードの情報を必ず必要とするクライアント
- SVCB-optional: SVCBレコードがなくても接続できるが、あれば活用するクライアント

### SvcParams
- SVCB / HTTPSレコードに記述されるサービスパラメータ群
  - alpn: 対応するアプリケーション層プロトコル (e.g. `h2=HTTP/2`、`h3=HTTP/3`)
  - no-default-alpn: デフォルトで有効なプロトコル(= http/1.1)に対応していないことを示す
  - port: 接続先ポート番号
  - ipv4hint / ipv6hint: サーバのIPアドレス (A / AAAAで得られた情報がある場合はそちらを優先)
  - ech: ECH (Encrypted Client Hello) を利用するために必要なサーバの公開鍵

### SvcPriorityに対する接続成功の要件
1. TCPハンドシェイクの完了
2. TLSハンドシェイクの完了
3. ALPNネゴシエーションの成功 (SvcParamsに`alpn`が含まれている場合)
4. ECHハンドシェイクの成功 (SvcParamsに`ech`が含まれ、かつSVCB-reliantクライアントの場合)

## 参照
- [HTTPSレコードがRFCになりました](https://eng-blog.iij.ad.jp/archives/23963)
- [Amazon Route 53の新しいHTTPS/SVCB/SSHFP/TLSAリソースレコードタイプについての技術概説とユースケースの考察](https://business.ntt-east.co.jp/content/cloudsolution/ih_column-154.html#section-2)
