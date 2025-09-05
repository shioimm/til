# net/http 現地調査 (202509時点)
https://github.com/golang/go/tree/master/src/net/http

### `type Request struct`

```go
// go/src/net/http/request.go
type Request struct {
    Method             string        // HTTP メソッド
    URL               *url.URL       // リクエスト先のURL go/src/net/url/url.go
    Proto              string        // プロトコルのバージョン e.g. "HTTP/1.0"
    ProtoMajor         int           // プロトコルのメジャーバージョン e.g. 1
    ProtoMinor         int           // プロトコルのマイナーバージョン e.g. 0

    Header             Header        // HTTPヘッダの集合 go/src/net/http/header.go
    Body               io.ReadCloser // リクエストボディ go/src/io/io.go
    Close              bool          // Keep-Aliveしない = true
    Host               string        // Hostヘッダを上書きできる
    ContentLength      int64         // Content-Length
    TransferEncoding []string        // Transfer-Encoding 通常は"chunked"

    GetBody func() (io.ReadCloser, error) // Bodyのコピーを返す (クライアントのリダイレクト用)

    Form           url.Values     // URLフィールドのクエリパラメータ、POST/PATCH/PUTフォームデータ
    PostForm       url.Values     // POST/PATCH/PUTのbodyから解析されたフォームデータ
    MultipartForm *multipart.Form // マルチパートフォーム go/src/mime/multipart/formdata.go

    Trailer    Header // HTTP Trailer
    RemoteAddr string // クライアントの "IP:port"
    RequestURI string // クライアントが送信するリクエストラインのURI

    TLS      *tls.ConnectionState // TLSの暗号スイートや証明書を格納
    Cancel <-chan struct{}        // リクエストキャンセル用 (廃止予定)
    Response *Response            // リダイレクトによって作られたリクエストが持つ元レスポンス
    Pattern   string              // ServeMuxがマッチしたパターン
    ctx       context.Context     // 内部的に保持されるコンテキスト
    pat         *pattern          // the pattern that matched
    matches     []string          // values for the matching wildcards in pat
    otherValues map[string]string // for calls to SetPathValue that don't match a wildcard
}
```

### `type Response struct`

```ruby
type Response struct {
    Status     string // ステータス行 e.g. "200 OK"
    StatusCode int    // ステータスコード
    Proto      string // プロトコルバージョン e.g. "HTTP/1.0"
    ProtoMajor int    // プロトコルメジャーバージョン e.g. 1
    ProtoMinor int    // プロトコルマイナーバージョン e.g. 0

    Header             Header        // レスポンスヘッダ
    Body               io.ReadCloser // レスポンスボディ
    Close              bool          // Keep-Aliveしない = true
    ContentLength      int64         // Content-Length
    TransferEncoding []string        // Transfer-Encoding
    Uncompressed       bool          // Transportが自動でgzipなどを解凍した場合 = true

    Trailer  Header  // HTTP Trailer
    Request *Request // 元のリクエストへのポインタ

    TLS *tls.ConnectionState // TLSの暗号スイートや証明書を格納
}
```

### `type Client struct`

```go
// 単一のHTTPトランザクションを実行するためのインターフェース
// Requestを受け取り、Responseを返す
type RoundTripper interface {
    RoundTrip(*Request) (*Response, error)
}

type Client struct {
    Transport RoundTripper // 実際にリクエストを送信する仕組みを指定する (デフォルトではDefaultTransport)

    // go/src/net/http/transport.go
    // var DefaultTransport RoundTripper = &Transport{
    //     Proxy: ProxyFromEnvironment,             // 環境変数HTTP_PROXY、NO_PROXYを尊重
    //     DialContext: (&net.Dialer{               // ネットワーク接続にnet.Dialerを利用する
    //         Timeout:   30 * time.Second,
    //         KeepAlive: 30 * time.Second,
    //     }).DialContext,
    //     ForceAttemptHTTP2:     true,             // HTTP/2を利用する
    //     MaxIdleConns:          100,              // 接続プールの管理
    //     IdleConnTimeout:       90 * time.Second, // 接続プールの管理
    //     TLSHandshakeTimeout:   10 * time.Second, // TLS接続タイムアウト値
    //     ExpectContinueTimeout: 1 * time.Second,  // Expect: 100-continue ヘッダのタイムアウト値
    // }

    Jar     CookieJar     // Cookieの保存場所 go/src/net/http/jar.go
    Timeout time.Duration // リクエスト全体のタイムアウト go/src/time/time.go

    CheckRedirect func(req *Request, via []*Request) error // リダイレクト時に呼ばれるコールバック
}
```
