# DHCPv6
- IPv6アドレスの自動設定

### ステートレスDHCPv6
- サーバーはDNSなどの情報のみを配布し、IPv6アドレス設定はクライアントが行う (SLAACなど)
- DNS情報はNDPのRouter Advertisementメッセージを利用することでも得られるが
  ステートレスDHCPv6による方法のほうがより多くの情報を配布できる (RFC 8106時点)
  - 通信端末によっていずれかのプロトコルが実装されていないケースもあり得る

## 動作フロー
1. DHCPv6クライアントがInformation Rrequestメッセージをマルチキャスト
    - 宛先: ff02::1:2 (`All_DHCP_Relay_Agents_and_Servers`)
2. DHCPv6サーバーがオプション要求オプションに対応する情報を含めたReplyメッセージを送信

### ステートフルDHCPv6
- DHCPサーバ側でクライアントへIPv6アドレスをリースする (リース期間も制御可能)

#### 動作フロー
1. DHCPv6クライアントがSolicitメッセージをマルチキャスト
    - 宛先: ff02::1:2 (`All_DHCP_Relay_Agents_and_Servers`)
2. DHCPv6サーバーがAdvertiseメッセージを送信
    - 設定情報の送信
3. DHCPv6クライアントがRequestメッセージを送信
    - 設定情報の確認
4. DHCPv6サーバーがReplyメッセージを送信
    - 設定情報を送信

### DHCPv6-PD
- DHCPv6サーバ (ルータ) がDHCPv6クライアント (ルータ) に対してIPv6プレフィックスを委任する
- ブロードバンドルータなどのCPEに対してIPv6アドレスプレフィックスを割り当てる用途に使われる

## DUID
- DHCPクライアントとDHCPサーバがそれぞれ通信相手を識別するために利用される識別子

#### 種類
- DUID-LLT - リンク層アドレスと時刻を組み合わせたDUID
- DUID-EN - ベンダーを表す32ビットのエンタープライズ番号とデバイスごとに一意な識別子を組み合わせたDUID
- DUID-LL - リンク層アドレスを利用したDUID
- DUID-UUID - RFC4122で定義されている128ビットのUUID

## 参照
- プロフェッショナルIPv6 8
