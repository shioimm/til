# Happy Eyeballs [RFC6555 / RFC8305]
- IPv6 / IPv4がいずれも利用可能な環境 (デュアルスタック環境) において
  通信状態の良い方を優先して接続する仕組み
- 通信開始時点でIPv6 / IPv4両プロトコルを用いて通信先と接続を行い、
  先に接続に成功した方のプロトコルから得られた結果をユーザーへ出力する

#### IPv6 / IPv4フォールバック
- IPv6 (IPv4) による通信が不可能な場合にIPv4 (IPv6) で接続し直す

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
