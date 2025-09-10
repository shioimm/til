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

## `type Transport struct`

```go
// go/src/net/http/transport.go

// WIP
type Transport struct {
    idleMu       sync.Mutex                          // Keep-Alive中の接続のテーブルを守るロック
    closeIdle    bool                                // Keep-Alive中の接続をすべてクローズするフラグ
    idleConn     map[connectMethodKey][]*persistConn // Keep-Alive中の接続のテーブル
    idleConnWait map[connectMethodKey]wantConnQueue  // 空き接続を待っているリクエストの待ち行列
    idleLRU      connLRU                             // Keep-Alive中の接続のLRU (最終利用時刻)

    // 進行中のリクエストにぶら下げたキャンセル関数のレジストリ
    reqMu       sync.Mutex
    reqCanceler map[*Request]context.CancelCauseFunc

    // 代替プロトコルのテーブル (キーはALPN等で得たプロトコル名)
    // デフォルト以外のRoundTripper (HTTP/2など) に切替えるために参照する
    altMu    sync.Mutex   // guards changing altProto only
    altProto atomic.Value // of nil or map[string]RoundTripper, key is URI scheme

    // 宛先ごとの総接続数カウンタ
    connsPerHostMu   sync.Mutex
    connsPerHost     map[connectMethodKey]int

    connsPerHostWait map[connectMethodKey]wantConnQueue // ホストあたりの同時接続数上限を超えたリクエストの待ち行列
    dialsInProgress  wantConnQueue                      // 接続中のリクエストの待ち行列

    Proxy func(*Request) (*url.URL, error) // プロキシ選択フック

    OnProxyConnectResponse func( // HTTPプロキシへCONNECTを送信した直後の応答フック
        ctx context.Context,
        proxyURL *url.URL,
        connectReq *Request,
        connectRes *Response
    ) error

    // 平文TCPの接続関数 (未設定ならnet.Dialer)
    DialContext func(ctx context.Context, network, addr string) (net.Conn, error)

    Dial func(network, addr string) (net.Conn, error)
    DialTLSContext func(ctx context.Context, network, addr string) (net.Conn, error)
    DialTLS func(network, addr string) (net.Conn, error)

    TLSClientConfig *tls.Config       // クライアントのTLSの設定
    TLSHandshakeTimeout time.Duration // TLS ハンドシェイクのタイムアウト

    DisableKeepAlives bool  // Keep-Aliveを使わず毎回つなぎ直す
    DisableCompression bool // Accept-Encoding: gzip を自動で付けない

    MaxIdleConns int        // Keep-Alive接続の上限 (全体)
    MaxIdleConnsPerHost int // Keep-Alive接続の上限 (ホスト別)
    MaxConnsPerHost int     // 接続中・使用中・Keep-Alive全てを含む総接続数の上限

    // Keep-Alive接続を自動クローズするまでの時間
    IdleConnTimeout time.Duration

    // リクエスト送信完了後、レスポンスヘッダが返るまでのタイムアウト時間
    ResponseHeaderTimeout time.Duration

    // Expect: 100-continueを送った後、最初のレスポンスヘッダが返るまでのタイムアウト時間
    ExpectContinueTimeout time.Duration

    // ALPNで選ばれたプロトコルに応じて別のRoundTripperに切替えるフック
    TLSNextProto map[string]func(authority string, c *tls.Conn) RoundTripper

    // CONNECT送信時に送るヘッダ
    ProxyConnectHeader Header

    // CONNECT送信毎に動的に決めるヘッダ
    GetProxyConnectHeader func(ctx context.Context, proxyURL *url.URL, target string) (Header, error)

    MaxResponseHeaderBytes int64 // レスポンスヘッダ総サイズの上限
    WriteBufferSize int          // 書き込み用のバッファサイズ
    ReadBufferSize int           // 読み取り用バッファサイズ

    nextProtoOnce      sync.Once   // Transport.RoundTripが最初に呼ばれるときにHTTP/2を有効化するかどうかを判定
    h2transport        h2Transport // 実際にHTTP/2リクエストを処理するRoundTripper
    tlsNextProtoWasNil bool        // TLSNextProtoフィールドがnilだったかどうか

    ForceAttemptHTTP2 bool // Dial*やTLSClientConfigをカスタムしていてもHTTP/2を試みる
    HTTP2 *HTTP2Config     // 予約領域
    Protocols *Protocols   // サポートするプロトコルの集合
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

## `Do`

```go
// go/src/net/http/client.go

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

            req = &Request{
                Method:   redirectMethod,
                Response: resp,         // 直前のレスポンス
                URL:      u,            // Locationを解決した新しいURL
                Header:   make(Header),
                Host:     host,
                Cancel:   ireq.Cancel,
                ctx:      ireq.ctx,     // 元リクエストのキャンセルチャネルとコンテキストを引き継ぐ
            }

            // includeBody = bodyを維持するか落とすかの判定 (ステータスコード次第)
            // ireq.GetBody = 巻き戻し可能なbody
            if includeBody && ireq.GetBody != nil { // bodyを再送する場合
                req.Body, err = ireq.GetBody()

                if err != nil {
                    resp.closeBody()
                    return nil, uerr(err)
                }

                req.GetBody = ireq.GetBody
                req.ContentLength = ireq.ContentLength
            }

            if !stripSensitiveHeaders && reqs[0].URL.Host != req.URL.Host {
                if !shouldCopyHeaderOnRedirect(reqs[0].URL, req.URL) {
                    stripSensitiveHeaders = true
                }
            }
            copyHeaders(req, stripSensitiveHeaders) // Sensitiveヘッダを除外しつつヘッダを複製

            // 直前のURLを元にRefererを追加
            if ref := refererForURL(reqs[len(reqs)-1].URL, req.URL, req.Header.Get("Referer")); ref != "" {
                req.Header.Set("Referer", ref)
            }

            err = c.checkRedirect(req, reqs) // Client.CheckRedirectの設定があれば実行

            if err == ErrUseLastResponse {
                return resp, nil
            }

            // 直前レスポンスボディを最大2KB読み捨ててからClose
            const maxBodySlurpSize = 2 << 10

            if resp.ContentLength == -1 || resp.ContentLength <= maxBodySlurpSize {
                io.CopyN(io.Discard, resp.Body, maxBodySlurpSize)
            }

            resp.Body.Close()

            if err != nil {
                ue := uerr(err)
                ue.(*url.Error).URL = loc
                return resp, ue
            }
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

// c.send(req, deadline)
func (c *Client) send(req *Request, deadline time.Time) (resp *Response, didTimeout func() bool, err error) {
    if c.Jar != nil {
        for _, cookie := range c.Jar.Cookies(req.URL) {
            req.AddCookie(cookie)
        }
    }

    resp, didTimeout, err = send(req, c.transport(), deadline)

    // func (c *Client) transport() RoundTripper {
    //     if c.Transport != nil {
    //         return c.Transport
    //     }
    //     return DefaultTransport
    // }

    if err != nil {
        return nil, didTimeout, err
    }

    if c.Jar != nil {
        if rc := resp.Cookies(); len(rc) > 0 {
            c.Jar.SetCookies(req.URL, rc)
        }
    }

    return resp, nil, nil
}

// send(req, c.transport(), deadline)
func send(ireq *Request, rt RoundTripper, deadline time.Time) (resp *Response, didTimeout func() bool, err error) {
    req := ireq // req is either the original request, or a modified fork

    if rt == nil {
        req.closeBody()
        return nil, alwaysFalse, errors.New("http: no Client.Transport or DefaultTransport")
    }

    if req.URL == nil {
        req.closeBody()
        return nil, alwaysFalse, errors.New("http: nil Request.URL")
    }

    // サーバ側の処理
    if req.RequestURI != "" {
        req.closeBody()
        return nil, alwaysFalse, errors.New("http: Request.RequestURI can't be set in client requests")
    }

    // reqのshallow copy (元のireqを直接書き換えないためのもの)
    forkReq := func() {
        if ireq == req {
            req = new(Request)
            *req = *ireq // shallow clone
        }
    }

    // ヘッダの初期化
    if req.Header == nil {
        forkReq()
        req.Header = make(Header)
    }

    // URLがユーザー情報を含み、かつAuthorizationヘッダの指定がない場合はBasic認証ヘッダを追加
    if u := req.URL.User;
       u != nil && req.Header.Get("Authorization") == "" {
        username := u.Username()
        password, _ := u.Password()
        forkReq()
        req.Header = cloneOrMakeHeader(ireq.Header)
        req.Header.Set("Authorization", "Basic "+basicAuth(username, password))
    }

    // deadlineが指定されている場合、リクエストをキャンセルできるようにする
    if !deadline.IsZero() {
        forkReq()
    }
    stopTimer, didTimeout := setRequestCancel(req, rt, deadline)

    // データの送信
    // rt = func (c *Client) transport() RoundTripper の返り値 (デフォルトではvar DefaultTransport RoundTripper)
    // なので rt.RoundTrip(req) = (*http.Transport).RoundTrip
    resp, err = rt.RoundTrip(req)

    // (go/src/net/http/roundtrip.go)
    // func (t *Transport) RoundTrip(req *Request) (*Response, error)

    if err != nil {
        stopTimer()
        if resp != nil {
            log.Printf("RoundTripper returned a response & error; ignoring response")
        }

        if tlsErr, ok := err.(tls.RecordHeaderError); ok {
            if string(tlsErr.RecordHeader[:]) == "HTTP/" { // HTTPSで送信してHTTPが返ってきた場合
                err = ErrSchemeMismatch
            }
        }

        return nil, didTimeout, err
    }

    // レスポンスがnilの場合
    if resp == nil {
        return nil, didTimeout, fmt.Errorf(
            "http: RoundTripper implementation (%T) returned a nil *Response with a nil error",
            rt
        )
    }

    // レスポンスボディがnilの場合
    if resp.Body == nil {
        if resp.ContentLength > 0 && req.Method != "HEAD" {
            return nil, didTimeout, fmt.Errorf(
                "http: RoundTripper implementation (%T) returned a *Response with content length %d but a nil Body",
                rt,
                resp.ContentLength
            )
        }

        resp.Body = io.NopCloser(strings.NewReader(""))
    }

    // deadlineが指定されている場合、レスポンスボディをcancelTimerBodyでラップする
    if !deadline.IsZero() {
        resp.Body = &cancelTimerBody{
            stop:          stopTimer,
            rc:            resp.Body,
            reqDidTimeout: didTimeout,
        }
    }

    return resp, nil, nil
}
```

## `RoundTrip`

```go
// go/src/net/http/roundtrip.go)

func (t *Transport) RoundTrip(req *Request) (*Response, error) {
    if t == nil {
        panic("transport is nil")
    }
    return t.roundTrip(req)
}

// go/src/net/http/transport.go
// WIP
func (t *Transport) roundTrip(req *Request) (_ *Response, err error) {
    t.nextProtoOnce.Do(t.onceSetNextProtoDefaults)
    ctx := req.Context()
    trace := httptrace.ContextClientTrace(ctx)

    if req.URL == nil {
        req.closeBody()
        return nil, errors.New("http: nil Request.URL")
    }
    if req.Header == nil {
        req.closeBody()
        return nil, errors.New("http: nil Request.Header")
    }
    scheme := req.URL.Scheme
    isHTTP := scheme == "http" || scheme == "https"
    if isHTTP {
        // Validate the outgoing headers.
        if err := validateHeaders(req.Header); err != "" {
            req.closeBody()
            return nil, fmt.Errorf("net/http: invalid header %s", err)
        }

        // Validate the outgoing trailers too.
        if err := validateHeaders(req.Trailer); err != "" {
            req.closeBody()
            return nil, fmt.Errorf("net/http: invalid trailer %s", err)
        }
    }

    origReq := req
    req = setupRewindBody(req)

    if altRT := t.alternateRoundTripper(req); altRT != nil {
        if resp, err := altRT.RoundTrip(req); err != ErrSkipAltProtocol {
            return resp, err
        }
        var err error
        req, err = rewindBody(req)
        if err != nil {
            return nil, err
        }
    }
    if !isHTTP {
        req.closeBody()
        return nil, badStringError("unsupported protocol scheme", scheme)
    }
    if req.Method != "" && !validMethod(req.Method) {
        req.closeBody()
        return nil, fmt.Errorf("net/http: invalid method %q", req.Method)
    }
    if req.URL.Host == "" {
        req.closeBody()
        return nil, errors.New("http: no Host in request URL")
    }

    // Transport request context.
    //
    // If RoundTrip returns an error, it cancels this context before returning.
    //
    // If RoundTrip returns no error:
    //   - For an HTTP/1 request, persistConn.readLoop cancels this context
    //     after reading the request body.
    //   - For an HTTP/2 request, RoundTrip cancels this context after the HTTP/2
    //     RoundTripper returns.
    ctx, cancel := context.WithCancelCause(req.Context())

    // Convert Request.Cancel into context cancelation.
    if origReq.Cancel != nil {
        go awaitLegacyCancel(ctx, cancel, origReq)
    }

    // Convert Transport.CancelRequest into context cancelation.
    //
    // This is lamentably expensive. CancelRequest has been deprecated for a long time
    // and doesn't work on HTTP/2 requests. Perhaps we should drop support for it entirely.
    cancel = t.prepareTransportCancel(origReq, cancel)

    defer func() {
        if err != nil {
            cancel(err)
        }
    }()

    for {
        select {
        case <-ctx.Done():
            req.closeBody()
            return nil, context.Cause(ctx)
        default:
        }

        // treq gets modified by roundTrip, so we need to recreate for each retry.
        treq := &transportRequest{Request: req, trace: trace, ctx: ctx, cancel: cancel}
        cm, err := t.connectMethodForRequest(treq)
        if err != nil {
            req.closeBody()
            return nil, err
        }

        // Get the cached or newly-created connection to either the
        // host (for http or https), the http proxy, or the http proxy
        // pre-CONNECTed to https server. In any case, we'll be ready
        // to send it requests.
        pconn, err := t.getConn(treq, cm)
        if err != nil {
            req.closeBody()
            return nil, err
        }

        var resp *Response
        if pconn.alt != nil {
            // HTTP/2 path.
            resp, err = pconn.alt.RoundTrip(req)
        } else {
            resp, err = pconn.roundTrip(treq)
        }
        if err == nil {
            if pconn.alt != nil {
                // HTTP/2 requests are not cancelable with CancelRequest,
                // so we have no further need for the request context.
                //
                // On the HTTP/1 path, roundTrip takes responsibility for
                // canceling the context after the response body is read.
                cancel(errRequestDone)
            }
            resp.Request = origReq
            return resp, nil
        }

        // Failed. Clean up and determine whether to retry.
        if http2isNoCachedConnError(err) {
            if t.removeIdleConn(pconn) {
                t.decConnsPerHost(pconn.cacheKey)
            }
        } else if !pconn.shouldRetryRequest(req, err) {
            // Issue 16465: return underlying net.Conn.Read error from peek,
            // as we've historically done.
            if e, ok := err.(nothingWrittenError); ok {
                err = e.error
            }
            if e, ok := err.(transportReadFromServerError); ok {
                err = e.err
            }
            if b, ok := req.Body.(*readTrackingBody); ok && !b.didClose.Load() {
                // Issue 49621: Close the request body if pconn.roundTrip
                // didn't do so already. This can happen if the pconn
                // write loop exits without reading the write request.
                req.closeBody()
            }
            return nil, err
        }
        testHookRoundTripRetried()

        // Rewind the body if we're able to.
        req, err = rewindBody(req)
        if err != nil {
            return nil, err
        }
    }
}
```

TODO
- `ForceAttemptHTTP2`の出番を調べる
