# example/client.rb
- [`http-2/lib/http/2/example/client.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/example/client.rb)

## 動作フロー
1. オプションパース
2. TLSを利用したプロトコルアップグレード・暗号化ソケットの生成
    - リクエストURIスキームがHTTPSではない場合: ソケットの生成
3. コネクションの作成
    - `HTTP2::Client`インスタンスを生成
4. ストリームの作成
    - `HTTP2::Client`インスタンスからアクティブな`HTTP2::Stream`インスタンスを生成
5. ロガーの生成
6. コネクションによるイベントの購読を登録
    - `:frame(frame)`
    - `:frame_sent(frame)`
    - `:frame_received(frame)`
    - `:promise(stream)`
      - `:promise_headers(frame[:payload])`
      - `:headers(frame[:payload])`
      - `:data(frame[:payload])`
    - `:altsvc` - デフォルトでは発信されていない
7. ストリームによるイベントの購読を登録
    - `:close(frame[:error])`
    - `:half_close(引数なし)`
    - `:headers(frame[:payload])`
    - `:data(frame[:payload])`
    - `:altsvc` - デフォルトでは発信されていない
8. リクエストヘッダの設定
9. GETの場合 - HEADERフレームの送信 / POSTの場合 - HEADERフレーム・DATAフレームの送信
10. ソケットが開いている限りループ処理を実行
    - レスポンスのうち1024バイトをノンブロッキングで読み込み
    - [begin]コネクションによる受信処理(`Connection#receive`)
      - `:frame_received`イベントの発信
      - 読み込んだデータ(`@recv_buffer`)から9バイトずつフレームを読み出す
      - フレームタイプ別の処理
    - [rescue]ソケットの切断
