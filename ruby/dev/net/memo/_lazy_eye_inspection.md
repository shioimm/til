# Lazy Eye Inspection: Capturing the State of Happy Eyeballs Implementations メモ
- https://arxiv.org/pdf/2412.00263
- https://www.happy-eyeballs.net

## Abstract
- HEのすべての機能をサポートしているのはSafariのみ
  - IPv4 Connection Attempt Delay、Resolution Delay、アドレスの交互配置
- ChromeとFirefox においては、IPv6の設定が完全に機能している場合であっても
  DNSにおいてAレコードのルックアップに問題がある場合、ネットワーク接続が遅延したり中断されたりする

## 1 Introduction
- HEの目的はIPv6 の利用を促進すること
  - IPv6を優先しつつ、必要に応じてIPv4にフォールバックする
- この論文による成果:
  - (i) 7つのOS上の9種類のブラウザにおけるHE実装の評価
    - 多くの実装はHEv1 (RFC 6555) に限定されている
  - (ii) DNSリゾルバにおけるIPの選択とフォールバック時の挙動の測定
    - DNSリゾルバはデュアルスタック構成において一般にHE型のアプローチに依存していない
    - その挙動は非常に多様であり、厳密にIPv6を優先する運用者はほとんど存在しない
  - (iii) 複数のクライアント、異なるバージョンにわたってHE実装をテストするローカルテストフレームワーク
  - (iv) HEが考慮するすべてのプロトコルについてネットワーク遅延をエミュレートするWebベースのテストツール
