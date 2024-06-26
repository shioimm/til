# example/server.rb
- [`http-2/lib/http/2/example/server.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/example/server.rb)

## 動作フロー
1. オプションパース
    - `:secure`オプション
    - `:port`オプション
    - `:push`オプション
2. TLSを利用したプロトコルアップグレード・暗号化リスニングソケット(`OpenSSL::SSL::SSLServer`)の生成
    - リクエストURIスキームがHTTPSではない場合: リスニングソケット(`TCPServer`)の生成
3. ループ処理の開始
4. リスニングソケットへの接続要求を受け入れ、接続ソケットを生成
    - コネクションの作成
5. コネクションの作成
    - `HTTP2::Server`インスタンスを生成
      - `@stream_id = 2`
      - `@state = :waiting_magic`
      - `@local_role = :server`
      - `@remote_role = :client`
6. コネクションによるイベントの購読を登録
    - `:frame(frame)`
      - ソケットへの書き込み
    - `:frame_sent(frame)`
    - `:frame_received(frame)`
    - `:stream(stream)`
      - ロガーの生成
      - ストリームによるイベントの購読を登録
        - `:active(引数なし)`
        - `:close(frame[:error])`
        - `:headers(frame[:payload])`
        - `:data(frame[:payload])`
          - インメモリに`frame[:payload]`を格納する
        - `:half_close(引数なし)`
          - HEADERフレームの送信
          - サーバープッシュの実行
          - DATAフレーム(レスポンス)の送信
7. ループ処理の開始(接続ソケットがEOFに至るまで、またはクローズするまで)
8. リクエストのうち1024バイトをノンブロッキングで読み込み
9. [begin]コネクションによる受信処理(`Connection#receive`)
    - `:frame_received`イベントの発信
    - 読み込んだデータ(`@recv_buffer`)から9バイトずつフレームを読み出す
    - フレームタイプ別の処理
10. [rescue]接続ソケットの切断
