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

(1) NAT64プレフィックスの検出 (8.2 / 8.3)

1. RAのPREF64オプションを確認
    - PREF64あり -> NAT64プレフィックスあり -> (2) へ
2. PREF64なし -> RFC 7050に従いipv4only.arpaのAAAAを問い合わせ
    - NAT64プレフィックスあり -> (2) へ
3. RFC 7050でも検出失敗 -> DNS64を仮定する -> (2) へ

### メインフロー
(2) 非同期DNSクエリの開始 (Section 4)

- 入力がIPv4アドレスリテラルの場合 (8.1 / 8.2)
  - NAT64プレフィックスあり -> DNSクエリなし -> (4) でIPv6合成へ
  - DNS64のみ -> 合成不可、接続失敗 (終了)
- 入力がホスト名の場合
  - デュアルスタック: HTTPS / AAAA / A を問い合わせ
  - IPv6-only/mostly:
     - NAT64プレフィックスあり: HTTPS / AAAA / A
     - DNS64のみ: HTTPS / AAAA のみ

以下のいずれかを満たした時点で (3) へ
- 条件A:
  - 何らかの肯定的アドレス応答を受信、
    かつ優先アドレスファミリ (通常IPv6) の肯定・否定応答を受信、
    かつSVCB / HTTPSのサービス情報または否定応答を受信
- 条件B:
  - 何らかの肯定的アドレス応答を受信、
    かつ他の応答が届かないままResolution Delay (推奨50ms) が経過

(3) 解決された宛先アドレスのソート (Section 5)

- アプリケーションプロトコル・セキュリティ要件によるグループ化 (5.1)
  ALPNやECHの対応状況に基づき、クライアントにとって重要な差異がある場合のみグループを分ける
- -> サービス優先度によるグループ化 (5.2)
  SVCBレコードの優先度番号でグループ化 (同一優先度が複数ある場合はランダムシャッフル)
  SVCBに紐付かないAAAA / Aレコードは末尾に低優先度グループとして追加
- -> グループ内でのアドレス並び替え (5.3)
  RFC 6724に基づくアドレス選択ルール + RTT履歴 + 使用済みアドレス優先
  IPv6とIPv4がインタリーブされるように配置 (Preferred Address Family Count: 推奨1)

(4) [IPv6-only/mostly + NAT64プレフィックスあり] アドレス合成 (8.2)

- DNS解決で得られたAレコードのIPv4アドレス、およびSVCBレコード内の ipv4hint のIPv4アドレスに対して
  RFC 6052エンコーディング (PREF64プレフィックス + IPv4) でIPv6アドレスを合成する
- 合成したIPv6アドレスをアドレスリストの適切な位置に挿入してソートし直す

(5) 非同期接続試行の開始 (Section 6)

- ソート済みリストの先頭から順に、Connection Attempt Delay (推奨250ms) ごとに接続試行を開始
  最小値: 100ms / 最大値: 2秒 (ただし [MUST NOT] 10ms未満は禁止)
- いずれかの接続試行が成功した時点で:
  - 他のすべての進行中の試行をキャンセル
  - 未試行のアドレスを無視
  - 進行中の非同期DNSクエリもキャンセルしてよい
    (ただしDNSキャッシュ目的で約1秒は応答処理を継続すべき)

(6) 接続確立の判定 (6.1)

- TCP only: TCPハンドシェイク完了 = 成功
- TCP + TLS: TLSハンドシェイク完了まで待機してから他の試行をキャンセル
- QUIC: メインハンドシェイク完了 = 成功
- TLSハンドシェイクが進行中でまだ完了していない場合:
  - Next Connection Attempt Timerを「TLSハンドシェイク完了までの推定時間」に延長

### IPv6-only/mostly + 464XLAT非対応の場合のフォールバック

(7) Last Resort Local Synthesis (8.4)
DNS64環境で壊れたAAAAレコード (有効なAレコードあり・AAAAレコードは無効) を持つホスト名への接続が
全て失敗した場合の対応。
NAT64プレフィックスが既知 (PREF64あり、またはRFC7050で検出済み) の場合のみ実行可能。

- 最後の接続試行を開始した時点でLast Resort Local Synthesis Delay (推奨2s) タイマーを起動
- タイマーが発火してもまだ接続が成功していない場合:
  - AレコードをDNSに問い合わせ
  - 取得したIPv4アドレスをアプリケーションから直接渡されたIPv4リテラルとして扱い
    NAT64プレフィックスでIPv6アドレスをローカル合成
  - 合成したアドレスでHEアルゴリズム ((5)-(6)) を再実行

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

### Rubyに追加で必要な能力
- クライアントのネットワークがIPv6-onlyもしくはIPv6-mostlyかどうかの判定
  - クライアントデバイスが464XLATに対応しているかどうかの判定
  - PREF64の取得
  - NAT64プレフィックスの検出
  - ローカルIPv6アドレス合成
- 名前解決実装
  - DNSSECを利用したことを判定できる
  - デフォルトでDoHが利用できる?
  - DNSに対してHTTP RRを問い合わせる
- アドレスのグループ化と並び替え
  - SVCB/HTTPSレコードの問い合わせ
  - SVCBパラメータの解析、AliasMode / ServiceModeの判別、サービス優先度の取得
- 接続試行可能なエンドポイントの判定
  - SVCBのALPNセットとクライアントがサポートするプロトコルの照合
- SVCB応答が失敗した場合に接続試行をキャンセルするかどうかの判定
  - DNS応答が保護されているかどうかの判定
- 接続試行成功の判定
  - ハンドシェイク完了の検知
