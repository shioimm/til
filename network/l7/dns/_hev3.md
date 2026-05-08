# Happy Eyeballs Version 3 (HEv3)
- https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/
- https://datatracker.ietf.org/wg/happy/documents/
- Lazy Eye Inspection: Capturing the State of Happy Eyeballs Implementations
- QUIC通信を優先する Happy Eyeballs Version 3 の提案
  - https://asnokaze.hatenablog.com/entry/2023/10/26/014349

## Overviews
1. 非同期DNSクエリの開始
    - HTTPS / AAAA / A レコードのDNS問い合わせを非同期に開始
    - いずれかの条件を満たした時点で次のステップへ進む:
      - 何らかの肯定的アドレス応答を受信、
        かつ肯定・否定問わず優先アドレスファミリ (通常IPv6) の応答を受信、
        かつSVCB / HTTPSのサービス情報または否定応答を受信
      - 何らかの肯定的アドレス応答を受信、
        かつ他の応答が届かないままResolution Delayが経過
2. 解決された宛先アドレスのソート
    - アプリケーションプロトコル・セキュリティ要件によるグループ化
      - ALPNやECHの対応状況に基づき、クライアントにとって重要な差異がある場合のみグループを分ける
    - -> サービス優先度によるグループ化
      - SVCBレコードの優先度番号でグループ化 (同一優先度が複数ある場合はランダムにシャッフル)
    - -> グループ内でのアドレス並び替え
      - RFC 6724に基づく、IPv6とIPv4がインタリーブされるようにする
        - QUIC IPv6 -> QUIC IPv4 -> TCP IPv6 -> TCP IPv4
3. 非同期接続試行の開始
    - ソート済みリストの先頭から順に、Connection Attempt Delay (推奨250ms) ごとに接続試行を開始する
4. 1つの接続を確立し、他のすべての試行をキャンセルする

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
