# example/client.rb
- [`http-2/lib/http/2/example/client.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/example/client.rb)

## 動作フロー
1. オプションパース
    - `:payload`オプション
2. TLSを利用したプロトコルアップグレード・暗号化接続ソケット(`OpenSSL::SSL::SSLSocket`)の生成
    - リクエストURIスキームがHTTPSではない場合: 接続ソケット(`TCPSocket`)の生成
3. コネクションの作成
    - `HTTP2::Client`インスタンスを生成
      - `@stream_id = 1`
      - `@state = :waiting_connection_preface`
      - `@local_role = :client`
      - `@remote_role = :server`
4. ストリームの作成
    - `HTTP2::Client`インスタンスからアクティブな`HTTP2::Stream`インスタンスを生成
5. ロガーの生成
6. コネクションによるイベントの購読を登録
    - `:frame(frame)`
    - `:frame_sent(frame)`
    - `:frame_received(frame)`
    - `:promise(stream)`
      - ストリームによるイベントの購読を登録
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
10. ループ処理の開始(ソケットがEOFに至るまで、またはクローズするまで)
11. レスポンスのうち1024バイトをノンブロッキングで読み込み
12. [begin]コネクションによる受信処理(`Client#receive(frame)`)
    - 読み込んだデータ(`@recv_buffer`)から9バイトずつフレームを読み出す
    - フレームタイプ別の処理
13. [rescue]ソケットの切断
