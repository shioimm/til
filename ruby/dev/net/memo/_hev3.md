# Happy Eyeballs Version 3 (HEv3)
- https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/
- https://datatracker.ietf.org/wg/happy/documents/
- Lazy Eye Inspection: Capturing the State of Happy Eyeballs Implementations
- QUIC通信を優先する Happy Eyeballs Version 3 の提案
  - https://asnokaze.hatenablog.com/entry/2023/10/26/014349

## 動作フロー
### [前提] IPv6-only/mostly + 464XLAT非対応の検出
(0) ネットワーク検出 (Section 8)

- ルーティング可能なIPv6アドレスあり
- かつルーティング可能なIPv4アドレスなし
- かつDNSリゾルバのアドレスが存在する

上記を満たす場合はIPv6-only/mostly ネットワークと判断

- 464XLAT (CLAT) 対応: CLATが透過的にアドレス変換を行うため (1) は不要 -> (2) へ
- 464XLAT非対応: -> (1) へ

上記を満たさない場合 -> (2) へ

(1) IPアドレス合成 (8.2 / 8.3)

接続先がIPv4アドレスリテラルの場合

- scoped IPv4 prefixの場合 -> NAT64合成せずに (4) へ
  - 0.0.0.0/8
  - 127.0.0.0/8
  - 169.254.0.0/16
  - 255.255.255.255/32
- RAのPREF64オプションありの場合 -> PREF64を用いてIPv4アドレスをNAT64用IPv6アドレスへ合成し (4) へ
- RAのPREF64オプションなしの場合 -> RFC7050に従いNAT64 prefixを探索する
  - NAT64 prefixを検出した場合 -> 発見したprefixをIPv4アドレスをNAT64用IPv6アドレスへ合成し (4) へ
  - NAT64 prefixを検出できなかった場合 -> 接続失敗

接続先がホスト名の場合 (非同期DNSクエリの開始)

- RAのPREF64オプションありの場合
  - HTTPS / AAAA / A を問い合わせ
  - AレコードのIPv4アドレスとSVCB/HTTPSのipv4hintをPREF64でNAT64用IPv6アドレスへ合成して (3) へ
- RAのPREF64オプションなしの場合 -> RFC7050に従いNAT64 prefixを探索する
  - NAT64 prefixを検出した場合
    - HTTPS / AAAA / A を問い合わせ
    - AレコードのIPv4アドレスとSVCB/HTTPSのipv4hintをPREF64でNAT64用IPv6アドレスへ合成して (3) へ
  - NAT64 prefixを検出できなかった場合
    - DNS64に依存していると仮定してSVCB/HTTPS、AAAAを問い合わせる
    - 通常はDNS64により合成AAAAを受け取り (4) へ

### メインフロー
(2) 非同期DNSクエリの開始 (Section 4)

- HTTPS / AAAA / A を問い合わせ

以下のいずれかを満たした時点で (3) へ

- 条件A:
  - 何らかの肯定的アドレス応答を受信、
    かつ優先アドレスファミリ (通常IPv6) の肯定・否定応答を受信、
    かつSVCB / HTTPSのサービス情報または否定応答を受信
- 条件B:
  - 何らかの肯定的アドレス応答を受信、
    かつ他の応答が届かないままResolution Delay (推奨50ms) が経過

(3) 解決された宛先アドレスのソート (Section 5)

1. アプリケーションプロトコル・セキュリティ要件でグループ化 (5.1)
    - ALPNやECHの対応状況に基づき、クライアントにとって重要な差異がある場合のみグループを分ける
2. SVCB/HTTPSのservice priorityでグループ化 (5.2)
    - 同一priorityのservice groupはランダムシャッフル
    - SVCBに紐付かないAAAA / Aレコードは末尾に低優先度グループとして追加
3. グループ内でのアドレス並び替え (5.3)
    - RFC 6724に基づくアドレス選択ルール + RTT履歴 + 使用済みアドレス優先
    - IPv6とIPv4がインタリーブされるように配置 (Preferred Address Family Count: 推奨1)

(4) 非同期接続試行の開始 (Section 6)

- ソート済みリストの先頭から順に、Connection Attempt Delay (推奨250ms) ごとに接続試行を開始
  最小値: 100ms / 最大値: 2秒 (ただし [MUST NOT] 10ms未満は禁止)
- いずれかの接続試行が成功した時点で:
  - 他のすべての進行中の試行をキャンセル
  - 未試行のアドレスを無視
  - 進行中の非同期DNSクエリもキャンセルしてよい
    (ただしDNSキャッシュ目的で約1秒は応答処理を継続すべき)

(5) 接続確立の判定 (6.1)

- TCP only: TCPハンドシェイク完了 = 成功
- TCP + TLS: TLSハンドシェイク完了まで待機してから他の試行をキャンセル
- QUIC: メインハンドシェイク完了 = 成功
- TLSハンドシェイクが進行中でまだ完了していない場合:
  - Next Connection Attempt Timerを「TLSハンドシェイク完了までの推定時間」に延長

### IPv6-only/mostly + 464XLAT非対応の場合のフォールバック

(6) Last Resort Local Synthesis (8.4)

IPv6-only/mostly + DNS64環境で、valid A records と broken AAAA records を持つホスト名への対策

- 最後の接続試行を開始した時点でLast Resort Local Synthesis Delay (推奨2s) を開始
- タイマー発火時点でまだ接続成功していない場合:
  - 1. Aレコードを問い合わせてIPv4アドレスを取得
  - 2. 取得したIPv4アドレスをIPv4リテラルとして扱い、NAT64 prefixが利用可能ならIPv6アドレスをローカル合成
  - 3. 合成したアドレスでHEアルゴリズム ((5)-(6)) を再実行

### VPN環境 (Section 8.5)
- IPv6-only環境にてVPN経由で内部ホスト名を解決 (企業リゾルバがAのみ返却・AAAAを合成不可) している場合:
  - 企業リゾルバにAを問い合わせし、取得したIPv4をIPv4リテラルとして扱いNAT64プレフィックスでローカル合成し、
    接続試行する ((2) に統合)

## NSS経由での名前解決
- getaddrinfo(3)と名前解決ライブラリを統合するのは難しそう
- HTTPS RRだけ名前解決ライブラリで取得する?デフォルトオプションのセットを用意しておいて切り替えられるようにする?

## HTTPS RRを元にした並び替えの例

```text
example.com. 60 IN HTTPS 1 svc1.example.com. (
  alpn="h3,h2" ipv6hint=2001:****:****:**** ipv4hint=192.*.*.* ech=...
)

example.com. 60 IN HTTPS 1 svc2.example.com. (
  alpn="h2" ipv6hint=2001:****:****:**** ipv4hint=192.*.*.*
)
```

```text
// ServicePriorityが低いものを優先して展開する
// ServicePriorityが同じ場合は対応しているプロトコルを確認する

候補1.
  service: svc1.example.com.
  address: 2001:****:****:****
  transport: QUIC
  ALPN: h3
  ECH: あり

候補2.
  service: svc1.example.com.
  address: 192.*.*.*
  transport: QUIC
  ALPN: h3
  ECH: あり

候補3.
  service: svc1.example.com.
  address: 2001:****:****:****
  transport: TCP
  ALPN: h2
  ECH: あり

候補4.
  service: svc2.example.com.
  address: 2001:****:****:****
  transport: TCP
  ALPN: h2
  ECH: なし
```

## 構成要素
- NAT64: IPv6専用環境でのIPv4サービスへの接続
- DNS64: IPv6専用環境でAAAAレコードを合成
- 464XLAT: プラットフォームレベルの透過的アドレス変換
- PREF64 Prefix Discovery: NAT64プレフィックスをRAで検出
- Discovery of the IPv6 Prefix Used for IPv6 Address Synthesis: NAT64プレフィックスをDNSで検出
- SVCB / HTTPS Resource Records: 代替エンドポイント・プロトコル対応状況・ECH鍵・アドレスヒントの提供
- DNSSEC: DNS応答の暗号化保護
- 暗号化DNS: DoT / DoH / DoQ
- DNS Push Notifications: 接続確立中の動的なDNS応答変更
- ECH: TLS ClientHelloの暗号化
- ALPN: アプリケーション層プロトコルネゴシエーション
- QUIC: UDP上の多重化・セキュアトランスポート
- HTTP/3
- HTTP Alternative Services (Alt-Svc): SVCBと併用したプロトコルネゴシエーション

## HEv3のために考慮すること
#### IPv6-only / IPv6-mostly判定
- 判定条件: (判定できそう)
  - ルーティング可能なIPv6アドレスあり
  - かつルーティング可能なIPv4アドレスなし
  - かつDNSリゾルバのアドレスが存在する

#### IPv6-only / IPv6-mostlyの場合、464XLATサポート状況
- 判定条件: TODO

#### IPv6-only / IPv6-mostlyかつ464XLAT非サポートの場合、NAT64プレフィックスの検出
TODO

#### 名前解決実装
- DNSSECを利用したことを判定できる
- デフォルトでDoHが利用できる?
- DNSに対してHTTP RRを問い合わせる

#### アドレスのグループ化と並び替え
- SVCB/HTTPSレコードの問い合わせ
- SVCBパラメータの解析、AliasMode / ServiceModeの判別、サービス優先度の取得

#### 接続試行可能なエンドポイントの判定
- SVCBのALPNセットとクライアントがサポートするプロトコルの照合

#### SVCB応答が失敗した場合に接続試行をキャンセルするかどうかの判定
- DNS応答が保護されているかどうかの判定

#### 接続試行成功の判定
- ハンドシェイク完了の検知
