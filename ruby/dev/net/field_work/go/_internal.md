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

    // (go/src/net/http/transport.go)
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

## `NewRequest`

```go
// go/src/net/http/request.go
// req, err := http.NewRequest("GET", "https://example.com", nil)
func NewRequest(method, url string, body io.Reader) (*Request, error) {
    return NewRequestWithContext(context.Background(), method, url, body)
}

func NewRequestWithContext(ctx context.Context, method, url string, body io.Reader) (*Request, error) {
    if method == "" {
        method = "GET" // 歴史的経緯により?
    }

    if !validMethod(method) {
        return nil, fmt.Errorf("net/http: invalid method %q", method)
    }

    if ctx == nil {
        return nil, errors.New("net/http: nil Context")
    }

    // u = URL構造体
    u, err := urlpkg.Parse(url) // urlpkg "net/url"

    // (go/src/net/url/url.go)
    // type URL struct {
    //    Scheme      string    // URLスキーム
    //    Opaque      string    // encoded opaque data
    //    User        *Userinfo // username と password
    //    Host        string    // ホスト名 or ホスト名:ポート番号
    //    Path        string    // パス
    //    RawPath     string    // エンコードされたパス
    //    OmitHost    bool      // 出力時に空のホスト部を省略する = true
    //    ForceQuery  bool      // RawQueryが空でも末尾に?を出力する = true
    //    RawQuery    string    // クエリ文字列 (?抜き)
    //    Fragment    string    // フラグメント識別子 (#抜き)
    //    RawFragment string    // エンコードされたフラグメント識別子
    //}

    if err != nil {
        return nil, err
    }

    rc, ok := body.(io.ReadCloser)
    if !ok && body != nil {
        rc = io.NopCloser(body)
    }
    // The host's colon:port should be normalized. See Issue 14836.
    u.Host = removeEmptyPort(u.Host)
    req := &Request{
        ctx:        ctx,
        Method:     method,
        URL:        u,
        Proto:      "HTTP/1.1",
        ProtoMajor: 1,
        ProtoMinor: 1,
        Header:     make(Header),
        Body:       rc,
        Host:       u.Host,
    }
    if body != nil {
        switch v := body.(type) {
        case *bytes.Buffer:
            req.ContentLength = int64(v.Len())
            buf := v.Bytes()
            req.GetBody = func() (io.ReadCloser, error) {
                r := bytes.NewReader(buf)
                return io.NopCloser(r), nil
            }
        case *bytes.Reader:
            req.ContentLength = int64(v.Len())
            snapshot := *v
            req.GetBody = func() (io.ReadCloser, error) {
                r := snapshot
                return io.NopCloser(&r), nil
            }
        case *strings.Reader:
            req.ContentLength = int64(v.Len())
            snapshot := *v
            req.GetBody = func() (io.ReadCloser, error) {
                r := snapshot
                return io.NopCloser(&r), nil
            }
        default:
            // This is where we'd set it to -1 (at least
            // if body != NoBody) to mean unknown, but
            // that broke people during the Go 1.8 testing
            // period. People depend on it being 0 I
            // guess. Maybe retry later. See Issue 18117.
        }
        // For client requests, Request.ContentLength of 0
        // means either actually 0, or unknown. The only way
        // to explicitly say that the ContentLength is zero is
        // to set the Body to nil. But turns out too much code
        // depends on NewRequest returning a non-nil Body,
        // so we use a well-known ReadCloser variable instead
        // and have the http package also treat that sentinel
        // variable to mean explicitly zero.
        if req.GetBody != nil && req.ContentLength == 0 {
            req.Body = NoBody
            req.GetBody = func() (io.ReadCloser, error) { return NoBody, nil }
        }
    }

    return req, nil
}
```
