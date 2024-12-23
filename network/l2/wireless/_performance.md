# ワイヤレスネットワークのパフォーマンス要素
### 帯域幅
- 割り当てられた周波数帯域の大きさに比例してデータ転送速度は上がる
- 低周波数の信号はより遠くへ伝わり、大きなエリアをカバーするが、
  より大きなアンテナを必要とし、一つのアンテナにアクセスが集中する(マクロセル)
  - ブロードキャスト向き
- 高周波数の信号はより多くのデータを転送できるが、遠くまでは伝わらないため、
  カバレッジが小さくなり、多くの設備が必要となる(マイクロセル)
  - 双方向通信向き

### 信号強度
- `信号対雑音比(S/N比)` = `信号レベル / ノイズ・干渉`
  - 全ての無線通信は他のデバイスによる予期しない干渉が起こる可能性がある
  - 通信速度を落とさないためには信号の出力を上げるか送受信の距離を縮めることが必要

#### 遠近問題
- 受信者が強い信号を受信することにより、弱い信号を受信できなくなる状態

#### セルブリージング
- カバーされているエリア・信号到達距離がノイズや干渉レベルによって拡大・縮小する状態

### 変調
- デジタル・アナログ変換プロセス
  - 各種変調アルファベット(それぞれ異なる効率でデジタル信号を変換する)と、
    シンボルレートの組み合わせによって最終スループットが決まる

### ワイヤレスネットワークのパフォーマンスに影響を与える要素
- 送信者と受信者の距離
- 現在地のバックグラウンドノイズの大きさ
- 同じネットワーク内のユーザーによる干渉(セル内干渉)の大きさ
- 近くの異なるネットワークのユーザーによる干渉(セル間干渉)の大きさ
- 送信者と受信者が利用可能な出力
- 計算能力と変調アルゴリズム

## 参照
- ハイパフォーマンスブラウザネットワーキング
