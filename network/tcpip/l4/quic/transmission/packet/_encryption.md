# QUICパケットの暗号化
- QUICパケットは復号時に改竄されていないことがわかる認証付き暗号で暗号化される
  - 暗号化の対象はヘッダの一部 (パケット番号など) とペイロード
    - ヘッダのうち暗号化されていない部分も改竄時は検知できる

### 暗号化に使用する鍵の種類
- パケットの種類ごとに鍵の種類が異なる

| パケットの種類 | 鍵の名前                      |
| -              | -                             |
| Initial        | Initial Keys                  |
| 0-RTT          | Early Data (0-RTT) Keys       |
| Handshake      | Handshake Keys                |
| 1-RTT          | Application Data (1-RTT) Keys |

- Initial Keysは通信の開始に必要・仕様で定義された固定値をもとに導出される
- Initial Keys以外はQUIC コネクションの確立時に得られた秘密値から導出される
- Application Data (1-RTT) Keysは長く使うため使用上限がある
  - 同一の鍵で暗号化を行なったデータ量が上限を超えた場合、鍵を更新する

## 参照
- WEB+DB PRESS Vol.123 HTTP/3入門
