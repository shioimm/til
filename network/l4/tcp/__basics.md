# TCP (Transmission Control Protocol)
- ストリームソケットが使用するコネクション指向のプロトコル
- アプリケーション層からは`SOCK_STREAM`で通信を行う

#### 特徴
- データの信頼性
  - 失われたパケットの再送
  - 順番の入れ替わったパケットの並べ直し
- 輻輳制御
  - スロースタート
  - 輻輳状態の検知
  - フロー制御
- ユニキャスト通信のみ可能

## 通信の確立
- 通信前に通信チャネルを確立する
- 送信データは複数のセグメントに分割される
  セグメントごとに送信エラーを検出可能なチェックサムを持つ
- TCPセグメントが受信側へ到着すると受信TCPは送信TCPへ確認応答を送信する

## 送受信バッファ
- TCPはホスト・ルーターの送受信バッファを使って送受信データを管理する
- 受信TCPは送信TCPから受信したデータを受信バッファに格納し、アプリケーションがデータを読み取ると削除する
- 送信TCPは送信するデータを送信バッファに格納し、送信条件が満たされている場合は送信する

## パケットの送信条件
- コネクションを確立済み
- 小さなデータパケットを連続して送信しない(Nagleアルゴリズム)
- 受信側のバッファに空きがある(フロー制御)
- ネットワークの混み具合が深刻ではない(輻輳制御)

### アプリケーションの動作と無関係に送信する条件
- データが届いたがしばらくACKを送信していなかった(遅延ACK 0.04s~0.2s)
- 送信したデータに対するACKの返信がない(再送制御 0.2s~1s)
- 受信バッファに空きができた(ウィンドウアップデート)
- 送信先から受信バッファの空きがないという通知があったしばらく後(ウィンドウプローブ)

## 送信セグメント長
- MSS(Maximum Segment Size)
  - 通信を行うデータサイズ
  - TCPはコネクション確立時に決定する
  - 理想的にはIPで分割処理されない最大のデータ長
- 大量のデータを送信する際はMSSの値ごとにデータが区切られて送信される
- MSSは3wayハンドシェイク時に送受信のホスト間で決められる
  - SYN送信時にTCPヘッダにMSSオプションを付加し、自分のインターフェースに適したMSSを通知する
  - 両ホストのMSSのうち、値が小さい方がMSSとして採用される

## 再送タイムアウト時間
- ACKの到着を待つ時間
  - TCPはパケットを送信するたびRTT(往復)時間とそのジッタ(揺らぎ)を計測する
  - RTT時間とジッタの時間を合計した値夜も少し大きな値を再送タイムアウト時間とする
  - 再送してもACKがない場合はExponential Backoffで再々送を行う
  - 再送回数が特定を越すと強制的にコネクションを切断し、アプリケーションに通信が異常終了したことを伝える

## HOLブロッキング(Head of Line Blocking)
- 通信路上で一部のパケットが失われた場合、それ以降のシーケンス番号を持つパケットは
  失われたパケットが再送されて届くまでの間、受信バッファに保持される
- アプリケーションは全てのデータが揃うまで処理を待機する
  - HOLブロッキングによる遅延はアプリケーション側には単なる伝送遅延と認識される

## TCPによるソケットプログラミングの流れ
- サーバーは`listen()`によりソケットをパッシブオープンし、`accept()`する
  `accept()`はコネクションが確立するまでブロックする
- クライアントは`connect()`によりソケットをアクティブオープンし、
  サーバーのパッシブソケットとのコネクションを確立する

#### サーバー
1. ソケットの作成(`socket(2)`)
2. 接続を待つIPアドレスとポート番号を設定
3. ソケットに名前をつける(`bind(2)`)
4. 接続を待つ(`listen(2)`)
5. 接続を受け付ける(`accept(2)`)
6. 通信を行う(`read(2)` / `write(2)`)
7. ソケットを閉じる(`close(2)`)

#### クライアント
1. ソケットの作成(`socket(2)`)
2. 接続する相手のIPアドレスとポート番号を設定
3. 接続要求を行う(`connect(2)`)
4. 通信を行う(`read(2)` / `write(2)`)
5. ソケットを閉じる(`close(2)`)

## 参照
- よくわかるHTTP/2の教科書P21-22/40-41
- Linuxプログラミングインターフェース 58章 / 61章
- Software Design 2021年5月号 ハンズオンTCP/IP
- ハイパフォーマンスブラウザネットワーキング
- マスタリングTCP/IP 入門編
- パケットキャプチャの教科書