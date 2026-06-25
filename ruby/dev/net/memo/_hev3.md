# Happy Eyeballs Version 3 (HEv3)
- https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/
- https://datatracker.ietf.org/wg/happy/documents/
- Lazy Eye Inspection: Capturing the State of Happy Eyeballs Implementations
- QUIC通信を優先する Happy Eyeballs Version 3 の提案
  - https://asnokaze.hatenablog.com/entry/2023/10/26/014349

## 動作フロー
### [前提] IPv6-only / mostly + 464XLAT非対応の検出
#### (0) ネットワーク / アドレスファミリ接続性の判定 (Section 8)

- IPv6-only / mostlyの判定:
  - ルーティング可能なIPv6アドレスあり
  - かつルーティング可能なIPv4アドレスなし
  - かつDNSリゾルバのアドレスが存在する
- 上記を満たさない場合 -> 宛先がホスト名の場合は (2) 、IPアドレスリテラルの場合は (4) へ
- 上記を満たす場合はIPv6-only/mostlyネットワークと判断し、IPv4の接続性を判定:
  - アドレスファミリ内に非ループバックのローカルアドレスが1つ以上ある
  - かつ非リンクローカルなルートが1つ以上ある
  - 上記を満たす場合 -> IPv4接続性ありとみなして宛先がホスト名の場合は (2) 、IPアドレスリテラルの場合は (4) へ
  - 上記を満たさない場合 -> IPv4接続性なしとみなして (1) へ

#### (1) IPアドレス合成 (8.2 / 8.3)

接続先がIPv4アドレスリテラルの場合

- scoped IPv4 prefixの場合 -> 接続候補として扱える場合はNAT64合成せずに (4) へ、そうでなければ接続失敗
  - 0.0.0.0/8
  - 127.0.0.0/8
  - 169.254.0.0/16
  - 255.255.255.255/32
- RAのPREF64オプションありの場合 -> PREF64を用いてIPv4アドレスをNAT64用IPv6アドレスへ合成し (4) へ
- RAのPREF64オプションなしの場合 -> ipv4only.arpaのAAAAを問い合わせて (RFC7050) NAT64 prefixを探索する
  - NAT64 prefixを検出した場合 -> 発見したprefixをIPv4アドレスをNAT64用IPv6アドレスへ合成し (4) へ
  - NAT64 prefixを検出できなかった場合 -> 接続失敗

接続先がホスト名の場合 (非同期DNSクエリの開始)

- RAのPREF64オプションありの場合
  - HTTPS / AAAA / A を問い合わせ
  - -> AレコードのIPv4アドレスとSVCB/HTTPSのipv4hintをPREF64でNAT64用IPv6アドレスへ合成して候補集合に追加
- RAのPREF64オプションなしの場合 -> ipv4only.arpaのAAAAを問い合わせて (RFC7050) NAT64 prefixを探索する
  - NAT64 prefixを検出した場合 (= ipv4only.arpaのAAAAが合成されている = DNS64が存在する)
    - HTTPS / AAAA を問い合わせ
    - -> ホスト名のAAAAはDNS64が合成して返すのでそれを候補集合に追加
    - -> SVCB/HTTPSのipv4hintはDNS64が合成しないため、検出したNAT64 prefixでローカル合成して候補集合に追加
    - (検出したprefixはIPv4リテラル接続 (8.1) や最終手段ローカル合成 (8.4 / 8.5) にも使う)
  - NAT64 prefixを検出できなかった場合
    - DNS64に依存していると仮定してSVCB/HTTPS、AAAAを問い合わせる
    - -> DNS64により合成AAAAを受け取り候補集合に追加

Section 4.2の条件Aまたは条件Bを満たしたら (3) へ

### メインフロー
#### (2) 非同期DNSクエリの開始 (Section 4)

- IPv6 + IPv4接続性ありの場合 -> HTTPS / AAAA / Aを問い合わせる
- IPv6接続性のみの場合 -> Section 8の判断に従い、HTTPS / AAAA / A または HTTPS / AAAAを問い合わせる
- IPv4接続性のみの場合 -> HTTPS / Aを問い合わせる

以下のいずれかを満たした時点で (3) へ

- 条件A:
  - 何らかの肯定的アドレス応答を受信、
    かつ優先アドレスファミリ (通常IPv6) の肯定・否定応答を受信、
    かつSVCB / HTTPSのサービス情報または否定応答を受信
- 条件B:
  - 何らかの肯定的アドレス応答を受信、
    かつ他の応答が届かないままResolution Delay (推奨50ms) が経過

#### (3) 解決された宛先アドレスのソート (Section 5)

1. アプリケーションプロトコル・セキュリティ要件でグループ化 (5.1)
    - ALPNやECHの対応状況に基づき、クライアントにとって重要な差異がある場合のみグループを分ける
2. SVCB/HTTPSのservice priorityでグループ化 (5.2)
    - 同一priorityのservice groupはランダムシャッフル
    - SVCBのどのサービスにも紐付かないAAAA / Aレコードは末尾に低優先度グループとして追加
3. グループ内でのアドレス並び替え (5.3)
    - RFC 6724に基づくアドレス選択ルール + RTT履歴 + 使用済みアドレス優先
    - IPv6とIPv4がインタリーブされるように配置 (Preferred Address Family Count: 推奨1)

#### (4) 非同期接続試行の開始 (Section 6)

- ソート済みリストの先頭から順に、Connection Attempt Delay (推奨250ms) ごとに接続試行を開始
  最小値: 100ms / 最大値: 2秒 (ただし [MUST NOT] 10ms未満は禁止)
- いずれかの接続試行が成功した時点で:
  - 他のすべての進行中の試行をキャンセル
  - 未試行のアドレスを無視
  - 進行中の非同期DNSクエリもキャンセルしてよい
    (ただしDNSキャッシュ目的で約1秒は応答処理を継続すべき)

#### (5) 接続確立の判定 (6.1)

- TCP only: TCPハンドシェイク完了 = 成功
- TCP + TLS: TLSハンドシェイク完了まで待機してから他の試行をキャンセル
- QUIC: メインハンドシェイク完了 = 成功
- TLSハンドシェイクが進行中でまだ完了していない場合:
  - Next Connection Attempt Timerを「TLSハンドシェイク完了までの推定時間」に延長
- ECHなど、暗号ハンドシェイクの内容がSVCB/HTTPS応答に依存する場合:
  - 条件によっては、TLS/QUICの暗号ハンドシェイク開始前にSVCB/HTTPS応答を待つ必要がある

### IPv6-only/mostly + 464XLAT非対応の場合のフォールバック
#### (6) Last Resort Local Synthesis (8.4)

IPv6-only/mostly + DNS64環境で、valid A records と broken AAAA records を持つホスト名への対策

- 最後の接続試行を開始した時点でLast Resort Local Synthesis Delay (推奨2s) を開始
- タイマー発火時点でまだ接続成功していない場合:
  - 1. Aレコードを問い合わせてIPv4アドレスを取得
  - 2. 取得したIPv4アドレスをIPv4リテラルとして扱い、NAT64 prefixが利用可能ならIPv6アドレスをローカル合成
  - 3. 合成したアドレスでHEアルゴリズム ((4)-(5)) を再実行

### VPN環境 (Section 8.5)
- IPv6-only環境にてVPN経由で内部ホスト名を解決 (企業リゾルバがAのみ返却・AAAAを合成不可) している場合:
  - 企業リゾルバにAを問い合わせし、取得したIPv4をIPv4リテラルとして扱いNAT64 prefixでローカル合成し、
    接続試行する ((2) に統合)

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
- PREF64 Prefix Discovery: NAT64 prefixをRAで検出
- Discovery of the IPv6 Prefix Used for IPv6 Address Synthesis: NAT64 prefixをDNSで検出
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
### IPv6-only / mostly対応
- IPv6-only / IPv6-mostlyを判定する
  - ルーティング可能なIPv6アドレスあり
  - かつルーティング可能なIPv4アドレスなし
  - かつDNSリゾルバのアドレスが存在する
- IPv6-only / IPv6-mostlyの場合、IPv4接続性を判定する
  - AF_INETの非ループバック・非リンクローカルなアドレスが1つ以上ある (`getifaddrs(3)`)
  - かつルートテーブルにIPv4の非リンクローカルなルートが1つ以上ある
  - OSによってルートテーブルのAPIが異なるのでUDP `connect(2)`プローブのほうがいいかも...?
- IPv6-only / IPv6-mostlyかつIPv4接続性なしの場合、NAT64 prefixを検出する
  - RAのPREF64オプションを取得するための汎用APIがない
    - Androidにはありそうだが...
  - ICMPv6 raw socketでRAを受信する実装を入れるのはハードルが高い
  - ipv4only.arpaのAAAAを問い合わせるほうが現実的かも
- NAT64 prefixのIPv6アドレスを合成する
  - なんとかする

### NSS経由での名前解決
- draftにNSSについての記述がない
- getaddrinfo(3)と名前解決ライブラリを統合するのは難しそう
- HTTPS RRを名前解決ライブラリ、AAAA / Aをgetaddrinfo(3)で取得する?
  - IPv6-only / IPv6-mostlyかつIPv4接続性なしの場合、AをIPv6にアドレス合成する必要あり
- もしくはデフォルトオプションのセットを用意しておいて切り替えられるようにする?

### DNSクエリの送受信
- なるべく近いタイミングで、HTTPSクエリ-> AAAAクエリ -> Aクエリの順に、IPv6で送信する
  - HTTPS RRの問い合わせのために名前解決ライブラリを使う必要あり
  - AAAA / A応答が返ってきていない場合、アドレスヒントをAAAA / A応答の代わりに利用する
    - 実際のAAAA / A応答が返ってき次第アドレスリスト内の候補を置き換える
- DNSSEC or DoT / DoHを利用する?
  - SVCBの解決が失敗した場合、接続試行を放棄する必要あり (ダウングレード攻撃を回避するため)
- DNSSEC or DoT / DoHを利用する、かつセキュリティ関連のSVCBパラメータ ("ech" SvcParamKeyなど) をサポートする、
  かつ当該プロトコル機能の有効化にそのSVCBパラメータを利用する?
  - SVCB応答を受信するまでTLSハンドシェイクの開始を保留する必要あり
- getaddrinfo(3)、c-ares、resolvライブラリは現状DNSSEC or DoT / DoHをサポートしていない
  - 暗号化させたい場合はローカルプロキシが必要そう...
  - ちなみに暗号化DNSを使用している場合:
    - 「有効なHTTPS応答を受信するまでTCPハンドシェイク後に非暗号化データを送信してはならない」 (11)
    - 「SVCB応答が失敗した場合に接続試行をキャンセルする」 (11)
    - 「有効なHTTPS応答を受信していない限り、TCPハンドシェイク完了後に非暗号化データを送信してはならない」 (11)

### アドレスリストの作成
- SVCBパラメータの解析、AliasMode / ServiceModeの判別、サービス優先度を取得できるようにする
- アドレスのグループ化と並び替えを行う機能を実装する
  - 新たにアドレスが追加された場合、Section 5のソートルールを全アドレスに適用して挿入位置を決定する
  - アドレスヒント由来のアドレスは、対応するAAAA / Aを受信した際にリストから削除するようにする
    - 既に接続試行が開始されたアドレスが削除されても、試行はキャンセルせず継続する

(グループ化と並べ替えの条件の整理)

- この時点でHTTPSの応答がない、あるいは否定応答があった場合:
  - AAAA / A全体を1グループとしてアドレスのソートを行う
- この時点でHTTPSの肯定応答があり、かつすべて同一レコードの場合:
  - アドレスヒントを含むAAAA / A全体を1グループとしてアドレスのソートを行う
- この時点でHTTPSの肯定応答があり、かつ異なるALPN / ECH等を持つ複数のレコードがある場合:
  - Step 1. 取得したアドレスをアプリケーションプロトコル・セキュリティ要件でグループ化・グループのソート
    - クライアントにとってクリティカルな差異がある場合のみ
    - 1つのアドレスが複数のグループに属する場合あり (e.g. alpn="h3,h2"のアドレスはh3グループとh2グループに属する)
  - Step 2. 1の各グループ内で取得したアドレスをSVCBサービス優先度でグループ化・グループのソート
    - TargetName "." のSVCBレコードがある: そのSVCBの優先度を同一オーナー名のAAAA/Aに適用してグループ化する
    - TargetNameが別名のSVCBレコードがある: そのTargetNameに対するAAAA / Aをサービスごとにグループ化する
    - 紐付くサービスを持たないAAAA/Aが残っている: 紐付かないAAAA / Aをリスト末尾の低優先度グループに置く
    - 同一優先度のサービスグループが複数ある: それらのグループをランダムシャッフルする
  - Step 3. 2の各サブグループ内でアドレスのソートを行う

### 複数グループある場合の接続試行
- Step 1の最優先グループ内のStep 2先頭グループから順に全Step 2グループ内の全アドレスを接続試行する
- Step 1の他グループへのフォールバックは実装定義

### Alt-Svcを使用する場合の接続試行
- Alt-SvcパラメータとSVCB ALPNセットの両方と整合することを確認する必要あり
  - Alt-Svcがh3を指定している & SVCBレコードのalpnにh3が含まれていない -> 接続すべきでない
  - SVCBレコードがalpn=h2,h3を広告している & Alt-Svcがh3を宣言していない -> 接続すべきでない

#### 接続試行成功の判定
- ハンドシェイク完了を検知する
  - 「クライアントアプリケーションが接続を使用可能と解釈する状態」
    - TCP only: TCPハンドシェイク完了
    - TCP + TLS: TLSハンドシェイク完了
    - QUIC: メインハンドシェイク完了
