# 状態遷移

| 状態                       | 入力                                            | 次の状態                   |
| -                          | -                                               | -                          |
| `開始`                     | IPv6 getaddrinfo()の実行                        | `IPv6 DNSクエリ開始`       |
| `開始`                     | IPv4 getaddrinfo()の実行                        | `IPv4 DNSクエリ開始`       |
| `IPv6 DNSクエリ開始`       | IPv6 getaddrinfo()の終了                        | `IPv6 DNSクエリ終了`       |
| `IPv6 DNSクエリ終了`       | 取得したアドレスを追加 & Resolution Delay無効化 | `接続試行確認`             |
| `IPv4 DNSクエリ開始`       | IPv4 getaddrinfo()の終了 & Resolution Delay有効 | `Resolution Delay`         |
| `IPv4 DNSクエリ開始`       | IPv4 getaddrinfo()の終了 & Resolution Delay無効 | `IPv4 DNSクエリ終了`       |
| `Resolution Delay`         | 50ms待機                                        | `IPv4 DNSクエリ終了`       |
| `IPv4 DNSクエリ終了`       | 取得したアドレスを追加                          | `接続試行確認`             |
| `接続試行確認`             | Connection Attempt Delay有効                    | `Connection Attempt Delay` |
| `接続試行確認`             | Connection Attempt Delay無効                    | `接続試行開始`             |
| `Connection Attempt Delay` | 250ms待機                                       | `接続試行確認`             |
| `接続試行開始`             | 接続確立                                        | `成功`                     |
| `接続試行開始`             | 接続失敗                                        | `エラー`                   |

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
- https://github.com/ruby/ruby/pull/4038#issuecomment-776417560
