# ストリーム
- 確立した一つのTCPコネクションの内部に作られる仮想チャネル

#### 性質
- ストリームは一意の整数IDを持つ
- 1ストリーム上で1リクエスト・1レスポンスのやりとりが行われる
- ストリームはフレームに付随するフラグによって簡単に作ったり閉じたりすることができる
- ストリーム単位ではTCPハンドシェイクは不要
- ストリームIDの数値とTCPの通信容量が許す限り並列接続を行うことができる
- 1コネクションにおいて使用済みの各ストリームは再利用されなくなる

## ストリームID
- 各ストリームは一意のストリームIDを持ち、同じIDを持つ一連のフレーム受信時にグループ化されて扱われる
  - 奇数ID - クライアントから通信を開始したストリーム(HTTPリクエスト)
  - 偶数ID - サーバーから通信を開始したストリーム(サーバープッシュ)
  - 数値0 - コネクションそのものを表すID
    - 制御用のやりとりや全てのストリームを指す
    - クライアント・サーバーどちらからでも発信可能

## ストリームの状態
- ストリームID 0以外のストリームは状態を持つ
- ストリームの状態はidleから始まり、フレームの送受信によって遷移する

### クライアントの状態
#### リクエスト送信時
1. idle
2. open - `HEADERS`フレーム送信 -> `END_STREAM`フラグ送信
3. half closed(ローカル) - `RST_STREAM`フレーム送信
4. closed

#### サーバプッシュ受信時
1. idle
2. reserved(リモート) - `PUSH_PROMISE`フレーム受信 -> `HEADERS`フレーム受信
3. half closed(ローカル) - `END_STREAM`フラグ受信
4. closed

### サーバーの状態
#### リクエスト受信時
1. idle
2. open - `HEADERS`フレーム受信 -> `END_STREAM`フラグ受信
3. half closed(リモート) - `RST_STREAM`フレーム受信
4. closed

#### サーバプッシュ送信時
1. idle
2. reserved(ローカル) - `PUSH_PROMISE`フレーム送信 -> `HEADERS`フレーム送信
3. half closed(リモート) - `END_STREAM`フラグ送信
4. closed

## 参照
- [普及が進む「http/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- [http の進化](https://developer.mozilla.org/ja/docs/web/http/basics_of_http/evolution_of_http)
- [そろそろ知っておきたいhttp/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- [request and response](https://youtu.be/0cmxvxmdbs8)
- [http/2とは](https://www.nic.ad.jp/ja/newsletter/no68/0800.html)
- [http/2](https://hpbn.co/http2/#binary-framing-layer)
- よくわかるhttp/2の教科書
- real world http 第2版
- ハイパフォーマンスブラウザネットワーキング
