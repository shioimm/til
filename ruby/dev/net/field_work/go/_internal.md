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

    Header             Header        // レスポンスヘッダ type Header map[string][]string (go/src/net/http/header.go)
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
    // DefaultClientによって利用される
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

// 再利用可能なHTTPクライアント
// トップレベル関数から内部的に呼ばれる
var DefaultClient = &Client{}
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
        ctx:        ctx,          // context.Background()
        Method:     method,       // "GET"
        URL:        u,            // "https://example.com"を表すURL構造体
        Proto:      "HTTP/1.1",   // デフォルト値ってこと?
        ProtoMajor: 1,
        ProtoMinor: 1,
        Header:     make(Header), // Headerマップのメモリアロケーション
        Body:       rc,           // nil のはず
        Host:       u.Host,       // example.com
    }

    // 以下のような感じでヘッダがセットされる
    // req.Header.Set("Accept", "text/html")

    // 以下GETの場合はスキップ
    // ContentLengthとGetBody (ボディを複製する関数) を設定する処理
    // HTTPリクエストは同じボディを何度も読み直す可能性がある (e.g. リダイレクト時の再送、認証チャレンジ後の再送)
    // io.Readerは一度読むと消費されてしまうため、
    // GetBodyを正しく実装できるのは巻き戻し可能な型*bytes.Buffer, *bytes.Reader, *strings.Reader に限定される
    if body != nil {
        switch v := body.(type) {
        case *bytes.Buffer:
            req.ContentLength = int64(v.Len())
            buf := v.Bytes()

            // GetBodyが呼ばれるたびに毎回新しいbytes.Readerをつくる
            req.GetBody = func() (io.ReadCloser, error) {
                r := bytes.NewReader(buf)
                return io.NopCloser(r), nil
            }
        case *bytes.Reader:
            req.ContentLength = int64(v.Len())

            // GetBodyが呼ばれるたびに*bytes.Readerをコピーして新しい *bytes.Reader を返す
            snapshot := *v
            req.GetBody = func() (io.ReadCloser, error) {
                r := snapshot
                return io.NopCloser(&r), nil
            }
        case *strings.Reader:
            req.ContentLength = int64(v.Len())

            // GetBodyが呼ばれるたびに*bytes.Readerをコピーして新しい *bytes.Reader を返す
            snapshot := *v
            req.GetBody = func() (io.ReadCloser, error) {
                r := snapshot
                return io.NopCloser(&r), nil
            }
        default:
            // nothing
        }

        // ContentLengthが0 == 本文なしリクエスト
        if req.GetBody != nil && req.ContentLength == 0 {
            req.Body = NoBody
            req.GetBody = func() (io.ReadCloser, error) { return NoBody, nil }
        }
    }

    return req, nil
}
```

```go
// go/src/net/http/client.go

// Transport (RoundTripper) はClientから内部的に利用される
func (c *Client) transport() RoundTripper {
    if c.Transport != nil {
        return c.Transport
    }
    return DefaultTransport
}

// req, err := http.NewRequest("GET", "https://example.com", nil)
// res, err := http.DefaultClient.Do(req)
func (c *Client) Do(req *Request) (*Response, error) {
    return c.do(req)
}

func (c *Client) do(req *Request) (retres *Response, reterr error) {
    // go/src/net/http/export_test.goの中でtestHookClientDoResultを実装している
    if testHookClientDoResult != nil {
        defer func() { testHookClientDoResult(retres, reterr) }()
    }

    // URLがnilの場合はエラーを返す
    if req.URL == nil {
        req.closeBody()
        return nil, &url.Error{
            Op:  urlErrorOp(req.Method),
            Err: errors.New("http: nil Request.URL"),
        }
    }
    _ = *c // panic early if c is nil; see go.dev/issue/53521

    var (
        deadline      = c.deadline()
        reqs          []*Request
        resp          *Response
        copyHeaders   = c.makeHeadersCopier(req)
        reqBodyClosed = false // have we closed the current req.Body?

        // Redirect behavior:
        redirectMethod        string
        includeBody           = true
        stripSensitiveHeaders = false
    )

    // uerr = エラーをフォーマットするための関数
    uerr := func(err error) error {
        if !reqBodyClosed {
            req.closeBody() // リクエスト本文 (req.Body) がまだ閉じられていなければクローズ
        }

        var urlStr string

        if resp != nil && resp.Request != nil { // サーバからレスポンスがあり、リダイレクトしている場合など
            urlStr = stripPassword(resp.Request.URL)
        } else {
            urlStr = stripPassword(req.URL)
        }

        return &url.Error{
            Op:  urlErrorOp(reqs[0].Method), // HTTPメソッド
            URL: urlStr, // URL
            Err: err, // エラー内容
        }
    }

    for {
        // For all but the first request, create the next request hop and replace req.
        // 以下の処理は2回目以降のループ = リダイレクトが発生した場合のみ実行
        if len(reqs) > 0 {
            loc := resp.Header.Get("Location")

            // Locationヘッダが無い3xxの場合は単にレスポンスを返す
            if loc == "" {
                return resp, nil
            }

            // リクエストURL基準にしてLocationを取得
            u, err := req.URL.Parse(loc)
            if err != nil {
                resp.closeBody()
                return nil, uerr(fmt.Errorf("failed to parse Location header %q: %v", loc, err))
            }

            host := ""

            // カスタムHostヘッダの指定ありかつ元のURLのホストと異なる
            if req.Host != "" && req.Host != req.URL.Host {
                // Locationが相対URL場合、リダイレクト後のリクエストでもHostヘッダを維持する
                if u, _ := url.Parse(loc); u != nil && !u.IsAbs() {
                    host = req.Host
                }
            }

            ireq := reqs[0]

            // ---- ここからWIP ----
            req = &Request{
                Method:   redirectMethod,
                Response: resp,
                URL:      u,
                Header:   make(Header),
                Host:     host,
                Cancel:   ireq.Cancel,
                ctx:      ireq.ctx,
            }

            if includeBody && ireq.GetBody != nil {
                req.Body, err = ireq.GetBody()
                if err != nil {
                    resp.closeBody()
                    return nil, uerr(err)
                }
                req.GetBody = ireq.GetBody
                req.ContentLength = ireq.ContentLength
            }

            // Copy original headers before setting the Referer,
            // in case the user set Referer on their first request.
            // If they really want to override, they can do it in
            // their CheckRedirect func.
            if !stripSensitiveHeaders && reqs[0].URL.Host != req.URL.Host {
                if !shouldCopyHeaderOnRedirect(reqs[0].URL, req.URL) {
                    stripSensitiveHeaders = true
                }
            }
            copyHeaders(req, stripSensitiveHeaders)

            // Add the Referer header from the most recent
            // request URL to the new one, if it's not https->http:
            if ref := refererForURL(reqs[len(reqs)-1].URL, req.URL, req.Header.Get("Referer")); ref != "" {
                req.Header.Set("Referer", ref)
            }
            err = c.checkRedirect(req, reqs)

            // Sentinel error to let users select the
            // previous response, without closing its
            // body. See Issue 10069.
            if err == ErrUseLastResponse {
                return resp, nil
            }

            // Close the previous response's body. But
            // read at least some of the body so if it's
            // small the underlying TCP connection will be
            // re-used. No need to check for errors: if it
            // fails, the Transport won't reuse it anyway.
            const maxBodySlurpSize = 2 << 10
            if resp.ContentLength == -1 || resp.ContentLength <= maxBodySlurpSize {
                io.CopyN(io.Discard, resp.Body, maxBodySlurpSize)
            }
            resp.Body.Close()

            if err != nil {
                // Special case for Go 1 compatibility: return both the response
                // and an error if the CheckRedirect function failed.
                // See https://golang.org/issue/3795
                // The resp.Body has already been closed.
                ue := uerr(err)
                ue.(*url.Error).URL = loc
                return resp, ue
            }
            // ---- ここまでWIP ----
        }

        // req, err := http.NewRequest("GET", "https://example.com", nil)
        // res, err := http.DefaultClient.Do(req)
        reqs = append(reqs, req) // reqsにreqを追加
        var err error
        var didTimeout func() bool

        // c.send(req, deadline)でリクエストを送信
        if resp, didTimeout, err = c.send(req, deadline);
           err != nil { // エラー発生時
            reqBodyClosed = true // c.send() always closes req.Body

            if !deadline.IsZero() && didTimeout() {
                err = &timeoutError{err.Error() + " (Client.Timeout exceeded while awaiting headers)"}
            }

            return nil, uerr(err)
        }

        var shouldRedirect, includeBodyOnHop bool
        redirectMethod, shouldRedirect, includeBodyOnHop = redirectBehavior(req.Method, resp, reqs[0])

        // func redirectBehavior(
        //     reqMethod string,
        //     resp *Response,
        //     ireq *Request
        // ) (redirectMethod string, shouldRedirect, includeBody bool) {
        //     switch resp.StatusCode {
        //     case 301, 302, 303:
        //         redirectMethod = reqMethod
        //         shouldRedirect = true
        //         includeBody = false
        //
        //         if reqMethod != "GET" && reqMethod != "HEAD" {
        //             redirectMethod = "GET"
        //         }
        //     case 307, 308:
        //         redirectMethod = reqMethod
        //         shouldRedirect = true
        //         includeBody = true
        //
        //         if ireq.GetBody == nil && ireq.outgoingLength() != 0 {
        //             shouldRedirect = false
        //         }
        //     }
        //     return redirectMethod, shouldRedirect, includeBody
        // }

        if !shouldRedirect {
            return resp, nil // 3xx以外ならそのままレスポンスを返して終了
        }

        if !includeBodyOnHop {
            includeBody = false
        }

        req.closeBody()
    }
}
```
