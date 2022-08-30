# HPKP (Public Key Pinning Extension for HTTP)
- HTTPのユーザエージェントに対する公開鍵ピンニングのための標準
- Public-Key-Pins (PKP) レスポンスヘッダを使ってHTTPレベルで設定される
  - Public-Key-Pinsヘッダが利用されるのはTLS でエラーがない場合のみ
  - 複数のヘッダがある場合は最初のヘッダのみが処理される
- 新しいPublic-Key-Pinsヘッダを受け取った場合以前に格納したピンニングの情報とメタデータを上書きする
- ポリシーの保持期間はmax-ageパラメータにて秒単位で設定される
- includeSubDomainsパラメータが使われている場合ピンニングの対象がサブドメインにも拡張される
- ピンニングはハッシュ関数とそのアルゴリズムで計算したSPKIフィンガープリントを指定することにより生成される
  - SPKI - SubjectPublicKeyInfo
- ピンニングを有効にする場合、ポリシーの保持期間を指定しピンニングする対象を少なくとも2 つ与える
  - 当該ピンニング指定を送信するのに使った接続に対する証明書チェーンに存在しているもの
  - 当該証明書チェーンに存在していないもの (バックアップ用)

## レポート
- Public-Key-Pinsヘッダにreport-uri命令を付けることでレポート機能を付加する
- HPKPのポリシー違反が発生した際、レポートが指定したURIへPOSTで送信されるようになる

```
{
  "date-time": "2014-04-06T13:00:50Z",
  "hostname": "www.example.com",
  "port": 443,
  "effective-expiration-date": "2014-05-01T12:40:50Z"
  "include-subdomains": false,
  "served-certificate-chain": [
    "-----BEGIN CERTIFICATE-----\n
    MIIEBDCCAuygAwIBAgIDAjppMA0GCSqGSIb3DQEBBQUAMEIxCzAJBgNVBAYTAlVT\n
    ...
    HFa9llF7b1cq26KqltyMdMKVvvBulRP/F/A8rLIQjcxz++iPAsbw+zOzlTvjwsto\n
    WHPbqCRiOwY1nQ2pM714A5AuTHhdUDqB1O6gyHA43LL5Z/qHQF1hwFGPa4NrzQU6\n
    yuGnBXj8ytqU0CwIPX4WecigUCAkVDNx\n
    -----END CERTIFICATE-----",
    ...
  ],
  "validated-certificate-chain": [
  "-----BEGIN CERTIFICATE-----\n
   MIIEBDCCAuygAwIBAgIDAjppMA0GCSqGSIb3DQEBBQUAMEIxCzAJBgNVBAYTAlVT\n
   ...
   HFa9llF7b1cq26KqltyMdMKVvvBulRP/F/A8rLIQjcxz++iPAsbw+zOzlTvjwsto\n
   WHPbqCRiOwY1nQ2pM714A5AuTHhdUDqB1O6gyHA43LL5Z/qHQF1hwFGPa4NrzQU6\n
   yuGnBXj8ytqU0CwIPX4WecigUCAkVDNx\n
   -----END CERTIFICATE-----",
   ...
  ],
  "known-pins": [
    "pin-sha256=\"d6qzRu9zOECb90Uez27xWltNsj0e1Md7GkYYkVoZWmM=\"",
    "pin-sha256=\"E9CZ9INDbd+2eRQozYqqbQ2yXLVKB9+xcprMF+44U1g=\""
  ]
}
```

## 参照
- プロフェッショナルSSL/TLS
