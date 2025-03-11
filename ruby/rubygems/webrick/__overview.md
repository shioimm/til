# WEBrick
- 汎用HTTPサーバーフレームワーク
- サーブレットによって機能し、サーブレットを作成することにより機能の追加ができる
  - サーブレット - サーバーの機能を抽象化しオブジェクトにしたもの
    - `WEBrick::HTTPServlet::AbstractServlet`のサブクラスのインスタンス

```ruby
require 'webrick'

# HTTPServerオブジェクトの生成
server = WEBrick::HTTPServer.new({ :DocumentRoot => './', :BindAddress => '127.0.0.1', :Port => 12345 })

# サーバー上のディレクトリにサーブレットをマウントさせる
server.mount('/img', WEBrick::HTTPServlet::FileHandler, '/home/username/images')

# シグナルハンドラの登録
trap('INT') { server.shutdown }

# サーバーを起動(WEBrick::GenericServer#start)
server.start
```

## 関連クラス
### サーバー
- [WEBrick::GenericServer](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aGenericServer.html)
  - [WEBrick::HTTPServer](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServer.html)

### リクエスト/レスポンス
- [WEBrick::HTTPRequest](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPRequest.html)
- [WEBrick::HTTPResponse](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPResponse.html)

### サーバータイプ
- [WEBrick::Daemon](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aDaemon.html)
- [WEBrick::SimpleServer](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aSimpleServer.html)

### サーブレット
- [WEBrick::HTTPServer::MountTable](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServer=3a=3aMountTable.html)
- [WEBrick::HTTPServlet::AbstractServlet](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aAbstractServlet.html)
  - [WEBrick::HTTPServlet::CGIHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aCGIHandler.html)
  - [WEBrick::HTTPServlet::DefaultFileHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aDefaultFileHandler.html)
  - [WEBrick::HTTPServlet::FileHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aFileHandler.html)
  - [WEBrick::HTTPServlet::ERBHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aERBHandler.html)
  - [WEBrick::HTTPServlet::ProcHandler](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPServlet=3a=3aProcHandler.html)

### 認証
#### Basic認証
- [WEBrick::HTTPAuth::BasicAuth](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPAuth=3a=3aBasicAuth.html)
  - [WEBrick::HTTPAuth::ProxyBasicAuth](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPAuth=3a=3aProxyBasicAuth.html)

#### Digest認証
- [WEBrick::HTTPAuth::DigestAuth](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPAuth=3a=3aDigestAuth.html)
  - [WEBrick::HTTPAuth::ProxyDigestAuth](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPAuth=3a=3aProxyDigestAuth.html)

#### Apache関連
- [WEBrick::HTTPAuth::Htdigest](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPAuth=3a=3aHtdigest.html)
- [WEBrick::HTTPAuth::Htgroup](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPAuth=3a=3aHtgroup.html)
- [WEBrick::HTTPAuth::Htpasswd](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPAuth=3a=3aHtpasswd.html)

### Cookie関連
- [WEBrick::Cookie](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aCookie.html)

### フォーム
- [WEBrick::HTTPUtils::FormData](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPUtils=3a=3aFormData.html)

### ログ
- [class WEBrick::BasicLog](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aBasicLog.html)
  - [class WEBrick::Log](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aLog.html)

### バージョン
- [WEBrick::HTTPVersion](https://docs.ruby-lang.org/ja/2.7.0/class/WEBrick=3a=3aHTTPVersion.html)

## 参照・引用
- [library webrick](https://docs.ruby-lang.org/ja/2.7.0/library/webrick.html)
