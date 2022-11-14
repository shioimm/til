# Happy Eyeballs [RFC6555 / RFC8305]
- IPv6 / IPv4がいずれも利用可能な環境 (デュアルスタック環境) において
  通信状態の良い方を優先して接続する仕組み
- 通信開始時点でIPv6 / IPv4両プロトコルを用いて通信先と接続を行い、
  先に接続に成功した方のプロトコルから得られた結果をユーザーへ出力する
- ホストの宛先アドレス優先ポリシーがIPv6を優先することを前提とする

#### IPv6 / IPv4フォールバック
- IPv6 (IPv4) による通信が不可能な場合にIPv4 (IPv6) で接続し直す

## 接続フロー
1. 非同期DNSクエリの開始
2. 解決済み宛先アドレスを優先順でソート
3. 非同期接続の試行開始
4. 接続を確立後、他の試行を破棄

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
