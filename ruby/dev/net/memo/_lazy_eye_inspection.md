# Lazy Eye Inspection: Capturing the State of Happy Eyeballs Implementations メモ
- https://arxiv.org/pdf/2412.00263
- https://www.happy-eyeballs.net

## Abstract
- HEのすべての機能をサポートしているのはSafariのみ
  - IPv4 Connection Attempt Delay、Resolution Delay、アドレスの交互配置
- ChromeとFirefox においては、IPv6の設定が完全に機能している場合であっても
  DNSにおいてAレコードのルックアップに問題がある場合、ネットワーク接続が遅延したり中断されたりする
