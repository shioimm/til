# サーブレット
- [WEBrick::HTTPServlet::AbstractServlet](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aAbstractServlet.html)
  - サーブレットの抽象クラス
- [WEBrick::HTTPServlet::DefaultFileHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aDefaultFileHandler.html)
  - ファイルサーバーとしての機能を提供するサーブレット
  - `WEBrick::HTTPServlet::FileHandler`の内部で使用される
- [WEBrick::HTTPServlet::FileHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aFileHandler.html)
  - ファイルサーバーとしての機能を提供するサーブレット
- [WEBrick::HTTPServlet::CGIHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aCGIHandler.html)
  - CGIを扱うサーブレット
- [WEBrick::HTTPServlet::ERBHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aERBHandler.html)
  - ERBを扱うサーブレット
- [WEBrick::HTTPServlet::ProcHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aProcHandler.html)
  - Procを扱うサーブレット
- [WEBrick::HTTPServer::MountTable](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServer=3a=3aMountTable.html)
  - サーバー上のパスとサーブレットの対応関係を管理するクラス

## サーブレットのマウント
```ruby
require 'webrick'

server = WEBrick::HTTPServer.new({ :DocumentRoot => './', :BindAddress => '127.0.0.1', :Port => 12345 })

server.mount('/view.cgi', WEBrick::HTTPServlet::CGIHandler, 'view.rb')

# 1. サーバーのパス'/view.cgi'とCGIHandlerサーブレットがマウントされる
# 2. サーバーのパス'/view.cgi'にリクエストが発生する
# 3. サーバーserverはオプション'view.rb'を引数としてCGIHandlerオブジェクトを生成
# 4. サーバーはリクエストオブジェクトを引数としてCGIHandler#serviceを呼ぶ
# 5. CGIHandlerオブジェクトは'view.rb'をCGIスクリプトとして実行
```

### `AbstractServlet#service`
- `service(request, response)` -> ()
  - リクエストに応じて必要な処理を呼ぶ
    - `request` - WEBrick::HTTPRequestオブジェクト
    - `response` - WEBrick::HTTPResponseオブジェクト

#### `AbstractServlet#service`が呼ぶメソッド
- 実際にどのような処理が行われるかはユーザー自身が実装する必要がある
  - `do_GET(request, response)` -> ()
  - `do_HEAD(request, response)` -> ()
  - `do_POST(request, response)` -> ()
  - `do_PUT(request, response)` -> ()
  - `do_DELETE(request, response)` -> ()
  - `do_OPTIONS(request, response)` -> ()
