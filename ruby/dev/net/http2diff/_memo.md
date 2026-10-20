# HEv3を組み込む作戦
- `Net::HTTP::Client::DEFAULTS`でHEv3を利用する/しないを設定できるようにする
- `ConnectionFactory.open`の`http.start`よりも前に名前解決の実行する必要あり
- `Net::HTTP#start` (`Connection#connect`) を拡張するのではなく、HEv3専用のAPIを用意した方がいいかも
  - 既存の`TCPSocket.open` -> `Net::HTTP#ssl_socket_connect`の流れが利用できない
    - アドレス解決 / TCP接続 / TLS接続を一箇所で待機する必要があるため
