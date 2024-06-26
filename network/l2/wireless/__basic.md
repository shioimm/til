# 無線通信
- 電波、赤外線、レーザー光線などを利用する通信
- 複数の無線LANの通信媒体と複数のクライアントホストが同時に物理的な空間に存在する場合、
  媒体間で無線の周波数帯域が共有されている
- 帯域の共有は帯域をチャンネルごとに分割し各通信に割り当てることによって実現している
  - チャンネル同士は完全に分離しておらずやや重複している
  - 一般には同じ帯域に共存する無線LANはお互いに重複しないチャンネルが割り当てられる

#### 通信の特徴
- 共有媒体 (電波) を利用して通信が行われる
- 特定の周波数帯に仕様が制限されている
- 出力が制限されている
- 常に変動するバックグラウンドノイズと干渉に依存する
- 選択されたワイヤレステクノロジーの技術的制約に依存する
- デバイスの形状・出力に依存する

## 無線通信の規格
- 無線通信は通信距離によって規格化団体や技術名称が異なる規格が数多く存在する

| 分類       | 通信距離        | 規格化団体             | 技術名称        |
| -          | -               | -                      | -               |
| 短距離無線 | 数m             | 個別                   | RF-ID           |
| 無線PAN    | 10m前後         | IEEE802.15             | Bluetooth       |
| 無線LAN    | 100m前後        | IEEE802.11             | Wi-Fi           |
| 無線MAN    | 数km~100km前後  | IEEE802.16、IEEE802.20 | WiMAX           |
| 無線RAN    | 200km~700km前後 | IEEE802.22             | -               |
| 無線WAN    | -               | 3GPP                   | 3G、LTE、4G、5G |

## 無線LAN
- 無線通信の中で、LANの範囲を比較的高速で接続するもの
- 無線LANは複数の端末が同じ周波数帯を共有する媒体共有型ネットワーク (CSMA/CA)
- 無線LANの規格では盗聴や改竄を防御するために送受信されるデータの暗号化などが定められている

## WiMAX
- Worldwide Interoperability for Microwave Access
- マイクロ波を使って無線接続を行う方式
- DSLやFTTHのようなラストワンマイルの接続を担う
- 無線MANはIEEE802.16の中で標準化が行われており、WiMAXはその一部

## AP (アクセスポイント)
- 有線LANと無線LANを相互に変換する機器
- ルータがAPの役割を兼ねていることが多い

## 参照
- マスタリングTCP/IP 入門編
