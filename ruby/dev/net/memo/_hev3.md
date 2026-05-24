# Happy Eyeballs Version 3 (HEv3)
- https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/
- https://datatracker.ietf.org/wg/happy/documents/
- Lazy Eye Inspection: Capturing the State of Happy Eyeballs Implementations
- QUIC通信を優先する Happy Eyeballs Version 3 の提案
  - https://asnokaze.hatenablog.com/entry/2023/10/26/014349

## 動作フロー
1. 非同期DNSクエリの開始 (4)
    - HTTPS / AAAA / A レコードのDNS問い合わせを非同期に開始(4.1)
    - いずれかの条件を満たした時点で次のステップへ進む (4.2):
      - 何らかの肯定的アドレス応答を受信、
        かつ肯定・否定問わず優先アドレスファミリ (通常IPv6) の応答を受信、
        かつSVCB / HTTPSのサービス情報または否定応答を受信
      - 何らかの肯定的アドレス応答を受信、
        かつ他の応答が届かないままResolution Delayが経過
2. 解決された宛先アドレスのソート (5)
    - アプリケーションプロトコル・セキュリティ要件によるグループ化 (5.1)
      - ALPNやECHの対応状況に基づき、クライアントにとって重要な差異がある場合のみグループを分ける
    - -> サービス優先度によるグループ化 (5.2)
      - SVCBレコードの優先度番号でグループ化 (同一優先度が複数ある場合はランダムにシャッフル)
    - -> グループ内でのアドレス並び替え (5.3)
      - RFC 6724に基づく、IPv6とIPv4がインタリーブされるようにする
        - QUIC IPv6 -> QUIC IPv4 -> TCP IPv6 -> TCP IPv4
3. 非同期接続試行の開始 (6)
    - ソート済みリストの先頭から順に、Connection Attempt Delay (推奨250ms) ごとに接続試行を開始する
4. 1つの接続を確立し、他のすべての試行をキャンセルする (6)

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
