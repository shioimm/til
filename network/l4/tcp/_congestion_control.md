# 輻輳回避と輻輳制御
## TCPにおけるレイテンシと輻輳制御
- 3wayハンドシェイクはパケット1往復分のレイテンシを発生させる
- スロースタートは全ての新規接続に適用される
- フロー制御と輻輳制御は全ての接続のスループットを制御する
- TCPのスループットは現在の輻輳ウィンドウサイズによって制限される
- 現代の高速ネットワークにおいてTCP接続の転送できるデータの速度は
  受送信ホスト間のパケット往復時間によって制限される

### 帯域幅遅延積
- `リンク容量 * エンドツーエンドの遅延` = 任意の時点における送信中未応答データの最大量
  - 送信側と受信側の最適なウィンドウサイズはパケット往復時間と目標データ転送速度に依存する
  - 許容される未応答データの最大量を超えた場合、次のデータ送信を延期し、
    相手がACKを返すまで(パケットの往復時間分)待機する必要がある
- ウィンドウサイズの通常ネットワークスタックによって自動的にネゴシエーション・チューニングされる

## チューニング
### サーバー設定
- システムのバージョンアップデートを行う
- TCP接続開始時の輻輳ウィンドウサイズを大きくする
- アイドル後のスロースタート(スロースタートリスタート)を無効にする
- ウィンドウスケーリングを有効にする
- TCP Fast Openを利用する

### アプリケーション
- 不要なデータ送信を除去する
- 送信データを圧縮する
- 物理的にサーバーをユーザーの近くに配置し、RTT時間を削減する
- 可能な限り既存のTCP接続を再利用する

## 参照
- よくわかるhttp/2の教科書p21-22/40-41
- linuxプログラミングインターフェース 58章 / 61章
- software design 2021年5月号 ハンズオンtcp/ip
- ハイパフォーマンスブラウザネットワーキング
