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

// if resp, didTimeout, err = c.send(req, deadline); (go/src/net/http/client.go)
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

// resp, didTimeout, err = send(req, c.transport(), deadline) (go/src/net/http/client.go)
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
// go/src/net/http/roundtrip.go

// rt.RoundTrip(req) (go/src/net/http/client.go)
func (t *Transport) RoundTrip(req *Request) (*Response, error) {
    if t == nil {
        panic("transport is nil")
    }
    return t.roundTrip(req)
}

// go/src/net/http/transport.go

func (t *Transport) roundTrip(req *Request) (_ *Response, err error) {
    // onceSetNextProtoDefaults (HTTP/2接続の判断と初期化) を一度だけ実行する
    // nextProtoOnceには初期化時にsync.Once{}がセットされている
    t.nextProtoOnce.Do(t.onceSetNextProtoDefaults)

    ctx := req.Context() // このリクエストにひもづくcontext.Contextを取得
    trace := httptrace.ContextClientTrace(ctx) // コンテキストに埋め込まれた*httptrace.ClientTraceを取得
    // ClientTrace = HTTPクライアントのライフサイクル各段階で呼ばれるコールバック群

    if req.URL == nil {
        req.closeBody()
        return nil, errors.New("http: nil Request.URL")
    }

    scheme := req.URL.Scheme
    isHTTP := scheme == "http" || scheme == "https"
    origReq := req
    req = setupRewindBody(req) // リクエストボディを再送可能にする

    // 以下バリデーション
    if req.Header == nil {
        req.closeBody()
        return nil, errors.New("http: nil Request.Header")
    }

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

    // ALPN等の結果に応じて別のRoundTripper (HTTP/2など) に振り替える場合の処理
    // altRTが存在したらそれを使ってリクエストを送る
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

    // 既存のreq.Context()を親として、キャンセル可能な子コンテキストを作成
    // このctxをTransport内部のI/Oに渡し、エラー時や完了時にはキャンセルする
    ctx, cancel := context.WithCancelCause(req.Context())

    // 互換性のための処理
    if origReq.Cancel != nil {
        go awaitLegacyCancel(ctx, cancel, origReq)
    }

    // 互換性のための処理
    cancel = t.prepareTransportCancel(origReq, cancel)

    // エラー時のキャンセルをdeferで実行
    defer func() {
        if err != nil {
            cancel(err)
        }
    }()

    for {
        // ループのたび、送信前にキャンセル/タイムアウトを検知したら、ボディをクローズしてエラー終了
        select {
        case <-ctx.Done():
            req.closeBody()
            return nil, context.Cause(ctx)
        default:
        }

        // req, trace, ctx, cancelをラップ
        // req = 今回送信する*http.Request
        // trace = *httptrace.ClientTrace のコールバック群
        // ctx, cancel: このトランザクション用のコンテキスト / キャンセル
        treq := &transportRequest{Request: req, trace: trace, ctx: ctx, cancel: cancel}

        cm, err := t.connectMethodForRequest(treq)

        // (go/src/net/http/transport.go)
        // このリクエストをどこへ、どうやって繋ぐか
        // func (t *Transport) connectMethodForRequest(treq *transportRequest) (cm connectMethod, err error) {
        //     cm.targetScheme = treq.URL.Scheme // リクエストのURLスキーム
        //     cm.targetAddr = canonicalAddr(treq.URL) // 実際に接続する"host:port"
        //
        //     if t.Proxy != nil { // Proxyフィールドが設定されていればcm.proxyURLに格納
        //         cm.proxyURL, err = t.Proxy(treq.Request)
        //     }
        //
        //     cm.onlyH1 = treq.requiresHTTP1() // HTTP/2 を禁止するフラグ
        //     return cm, err
        // }

        if err != nil {
            req.closeBody()
            return nil, err
        }

        // 接続を取得 (コネクションプール再利用 or 新規で接続確立)
        pconn, err := t.getConn(treq, cm)

        if err != nil {
            req.closeBody()
            return nil, err
        }

        var resp *Response

        if pconn.alt != nil {
            // pconn.alt = HTTP/2用のRoundTripper (*http2.Transport型もしくは *http2unencryptedTransport型)
            resp, err = pconn.alt.RoundTrip(req) // HTTP/2で送受信
        } else {
            resp, err = pconn.roundTrip(treq) // HTTP/1で送受信
        }

        if err == nil {
            if pconn.alt != nil {
                cancel(errRequestDone) // HTTP/2はCancelRequestが効かないので、ここでctxをクローズ
            }
            resp.Request = origReq // 元のリクエストをセット
            return resp, nil // レスポンスを返す
        }

        // 失敗した場合の処理
        if http2isNoCachedConnError(err) {
            if t.removeIdleConn(pconn) {
                t.decConnsPerHost(pconn.cacheKey)
            }
        } else if !pconn.shouldRetryRequest(req, err) {
            if e, ok := err.(nothingWrittenError); ok { // リトライしない
                err = e.error
            }

            if e, ok := err.(transportReadFromServerError); ok {
                err = e.err
            }

            if b, ok := req.Body.(*readTrackingBody); ok && !b.didClose.Load() {
                req.closeBody()
            }
            return nil, err
        }

        // リトライする場合はテスト用フックを呼んで続行
        testHookRoundTripRetried()

        // リトライ前にリクエストボディを巻き戻す
        req, err = rewindBody(req)

        if err != nil {
            return nil, err
        }
    }
}
```

## `onceSetNextProtoDefaults`

```go
// (go/src/net/http/transport.go)
func (t *Transport) onceSetNextProtoDefaults() {
    t.tlsNextProtoWasNil = (t.TLSNextProto == nil) // 初期化時点でTLSNextProtoがnilだったかどうか

    // HTTP/2を明示的に無効にしている場合は何もせずに終了
    if http2client.Value() == "0" {
        http2client.IncNonDefault()
        return
    }

    // 標準添付のhttp2ではなく、golang.org/x/net/http2を利用する場合 (マイグレーション用?)
    altProto, _ := t.altProto.Load().(map[string]RoundTripper)
    if rv := reflect.ValueOf(altProto["https"]);
       rv.IsValid() && rv.Type().Kind() == reflect.Struct && rv.Type().NumField() == 1 {
        if v := rv.Field(0); v.CanInterface() {
            if h2i, ok := v.Interface().(h2Transport); ok {
                t.h2transport = h2i
                return
            }
        }
    }

    // TLSNextProto["h2"]に値がセットされている場合はユーザ or 他所で初期化済み
    if _, ok := t.TLSNextProto["h2"]; ok {
        // There's an existing HTTP/2 implementation installed.
        return
    }

    // HTTP/2を有効化しない場合
    protocols := t.protocols()
    if !protocols.HTTP2() && !protocols.UnencryptedHTTP2() {
        return
    }

    // (go/src/net/http/transport.go)
    // どのプロトコルを有効にするか
    // func (t *Transport) protocols() Protocols {
    //     if t.Protocols != nil { // 明示的な指定がある
    //         return *t.Protocols
    //     }
    //
    //     var p Protocols
    //     p.SetHTTP1(true) // デフォルトではHTTP/1
    //
    //     switch {
    //     case t.TLSNextProto != nil:
    //         if t.TLSNextProto["h2"] != nil { // "h2"の指定がある
    //             p.SetHTTP2(true)
    //         }
    //     case !t.ForceAttemptHTTP2 && // カスタムTLS/Dialerが設定されている
    //          (t.TLSClientConfig != nil || t.Dial != nil || t.DialContext != nil || t.hasCustomTLSDialer()):
    //     case http2client.Value() == "0": // 無効が指定されている
    //         // do nothing
    //     default: // デフォルトではHTTP/2
    //         p.SetHTTP2(true)
    //         // (go/src/net/http/http.go)
    //         // func (p *Protocols) SetHTTP2(ok bool) { p.setBit(protoHTTP2, ok) }
    //     }
    //     return p
    // }

    // 標準添付のHTTP/2を省く指定がある場合
    if omitBundledHTTP2 {
        return
    }

    // 標準添付のHTTP/2実装をTransportにセット
    // (src/net/http/h2_bundle.go)
    // t2 := &http2Transport{
    //     ConnPool: http2noDialClientConnPool{connPool}, // http2noDialClientConnPool = 既存のTLS接続のプール
    //     t1:       t1,                                  // ここまでにTCP/TLS接続済みのTransport
    // }
    t2, err := http2configureTransports(t)

    if err != nil {
        log.Printf("Error enabling Transport HTTP/2 support: %v", err)
        return
    }

    // t.h2transportにhttp2Transportをセット
    t.h2transport = t2

    if limit1 := t.MaxResponseHeaderBytes; limit1 != 0 && t2.MaxHeaderListSize == 0 {
        const h2max = 1<<32 - 1
        if limit1 >= h2max {
            t2.MaxHeaderListSize = h2max
        } else {
            t2.MaxHeaderListSize = uint32(limit1)
        }
    }

    // ALPNの候補リストを更新
    t.TLSClientConfig.NextProtos = adjustNextProtos(t.TLSClientConfig.NextProtos, protocols)
}
```

## `http2configureTransports`

```go
// 標準添付のHTTP/2実装をTransportにセット
// t2, err := http2configureTransports(t)

// (src/net/http/h2_bundle.go)

func http2configureTransports(t1 *Transport) (*http2Transport, error) {
    // -- t2とコネクションプールの用意 --

    // http2clientConnPool = 接続を管理するプール
    //
    // (src/net/http/h2_bundle.go)
    // type http2clientConnPool struct {
    //     t *http2Transport // このプールがぶら下がる親
    //     mu sync.Mutex
    //     conns        map[string][]*http2ClientConn // 接続先のhost:port : [http2ClientConn, ...] のマップ構造
    //     dialing      map[string]*http2dialCall
    //     keys         map[*http2ClientConn][]string // http2ClientConn : [接続先のhost:port, ...] のマップ構造
    //     addConnCalls map[string]*http2addConnCall
    // }
    //
    // クライアントがhost:portへ送信する際、
    // conns[host:port]から接続を取得
    // -> なければdialing[host:port]から接続を取得するか、なければ新規接続を開始してdialingに追加
    // -> 接続に成功したらconns[host:port]に追加
    // -> 別ホスト名かつコアレッシング可能な場合はconns[別host:port]に同じ接続を追加
    // -> 接続を閉じる場合はkeys[http2ClientConn]とconns[host:port]を削除

    connPool := new(http2clientConnPool)

    // HTTP/2の接続の実体
    t2 := &http2Transport{
        ConnPool: http2noDialClientConnPool{connPool}, // http2noDialClientConnPool = 既存のTLS接続のプール
        t1:       t1,                                  // ここまでにTCP/TLS接続済みのTransport
    }

    // プール側からt2にアクセスできるようにする
    connPool.t = t2

    // -- ALPN候補を準備 --

    // t1のTLSNextProtoマップにh2プロトコルを登録する
    // t1.TLSNextProto["h2"]のような呼び出しを可能にする
    if err := http2registerHTTPSProtocol(t1, http2noDialH2RoundTripper{t2}); err != nil {
        return nil, err
    }

    // TLSクライアント設定の準備
    if t1.TLSClientConfig == nil {
        t1.TLSClientConfig = new(tls.Config)
    }

    // NextProtos = ClientHelloのALPN拡張で送る接続プロトコルの候補リスト
    // 先頭にh2を追加
    if !http2strSliceContains(t1.TLSClientConfig.NextProtos, "h2") {
        t1.TLSClientConfig.NextProtos = append([]string{"h2"}, t1.TLSClientConfig.NextProtos...)
    }
    // 末尾にhttp/1.1を追加
    if !http2strSliceContains(t1.TLSClientConfig.NextProtos, "http/1.1") {
        t1.TLSClientConfig.NextProtos = append(t1.TLSClientConfig.NextProtos, "http/1.1")
    }

    // -- ALPNでh2もしくはh2cが選ばれた場合に実行する関数を設定 --

    // 既存コネクションをh2用に登録→適切なRoundTripperを返す関数
    // scheme    = https (h2) / http (h2c)
    // authority = ALPN合意時にTransport.TLSNextProto経由で渡される"host:port"
    // c         = t1で確立済みのTCP/TLS接続
    upgradeFn := func(scheme, authority string, c net.Conn) RoundTripper {
        // addr = "scheme://host:port"
        addr := http2authorityAddr(scheme, authority)

        // すでに同じaddrと接続済みのClientConnがあるかどうかを確認
        // なければnet.Connからhttp2ClientConnを作ってconnPoolへ登録
        if used, err := connPool.addConnIfNeeded(addr, t2, c);
           err != nil { // このTCP/TLSは使わない
            go c.Close()
            return http2erringRoundTripper{err}
        } else if !used { // 同時に複数のダイヤルが実行され、いずれかが先に登録済みなど
            go c.Close()
        }

        if scheme == "http" {
            // http2unencryptedTransport = http2Transportの型エイリアス
            return (*http2unencryptedTransport)(t2) // h2c用の特別なRoundTripperとして返す
        }

        return t2
    }

    if t1.TLSNextProto == nil {
        // ALPNでh2もしくはh2cが呼ばれた場合にコールバックする関数を格納するためのレジストリを準備
        t1.TLSNextProto = make(map[string]func(string, *tls.Conn) RoundTripper)
    }

    // const http2NextProtoTLS = "h2"
    // t1.TLSNextProto["h2"]()を呼び出すと、cをもとにhttp2ClientConnを作成してconnPoolに登録
    // 返り値はt2
    t1.TLSNextProto[http2NextProtoTLS] = func(authority string, c *tls.Conn) RoundTripper {
        return upgradeFn("https", authority, c)
    }

    // const http2nextProtoUnencryptedHTTP2 = "unencrypted_http2"
    // t1.TLSNextProto["unencrypted_http2"]()を呼び出すと、cをもとにhttp2ClientConnを作成してconnPoolに登録
    // 返り値は(*http2unencryptedTransport)(t2)
    t1.TLSNextProto[http2nextProtoUnencryptedHTTP2] = func(authority string, c *tls.Conn) RoundTripper {
        nc, err := http2unencryptedNetConnFromTLSConn(c)

        if err != nil {
            go c.Close()
            return http2erringRoundTripper{err}
        }
        return upgradeFn("http", authority, nc)
    }

    // -- t2を返す --

    return t2, nil
}
```

## `getCon`

```go
// go/src/net/http/transport.go

// // treqはreq, trace, ctx, cancelをラップする
// // req: 今回送信する*http.Request
// // trace: *httptrace.ClientTrace のコールバック群
// // ctx, cancel: このトランザクション用のコンテキスト / キャンセル
// treq := &transportRequest{Request: req, trace: trace, ctx: ctx, cancel: cancel}
// cm, err := t.connectMethodForRequest(treq)
// pconn, err := t.getConn(treq, cm)

func (t *Transport) getConn(treq *transportRequest, cm connectMethod) (_ *persistConn, err error) {
    req := treq.Request
    trace := treq.trace
    ctx := req.Context()

    // http.Requestにコールバックが仕込まれている場合はGetConnを読んで通知
    if trace != nil && trace.GetConn != nil {
        trace.GetConn(cm.addr()) // cm.addr = 接続先の"host:port"
    }

    // リクエストのキャンセルに影響されない、かつTransport側で止められるコンテキストを作成する
    // = リクエストが途中でキャンセルされても接続試行中のTCP/TLSを捨てず、接続確立後は接続プールに追加したい
    dialCtx, dialCancel := context.WithCancel(
      context.WithoutCancel(ctx) // キャンセルとDone / Err / Deadlineを取り除いた新しいコンテキスト
    )
    // dialCtxを使用してKeep-Alive接続を獲得、または新規ダイヤルを行う

    w := &wantConn{
        cm:         cm,                        // connectMethod (どこにどう繋ぐか)
        key:        cm.key(),                  // 接続プールのキー
        ctx:        dialCtx,                   // ダイヤル用コンテキスト
        cancelCtx:  dialCancel,                // ダイヤル用コンテキストをキャンセルするための関数
        result:     make(chan connOrError, 1), // connOrError (接続結果) を1件流すチャネル
        beforeDial: testHookPrePendingDial,
        afterDial:  testHookPostPendingDial,
    }

    defer func() {
        if err != nil {
            w.cancel(t)
        }
    }()

    if delivered := t.queueForIdleConn(w); // 接続プールから即時に割り当てられる接続を取得
       !delivered { // 接続がない場合は新規ダイヤルの待機列にwantConnを追加
        t.queueForDial(w)
    }

    select {
    case r := <-w.result: // 結果待ち
        // r.pc = 取得できた接続 (persistConn)
        // HTTP/1の場合 (pconn.alt == nil) 、httptrace.GotConnを呼ぶ (HTTP/2は内部で自力でで呼ぶ)
        if r.pc != nil && r.pc.alt == nil && trace != nil && trace.GotConn != nil {
            info := httptrace.GotConnInfo{
                Conn:   r.pc.conn,       // 実際のnet.Conn
                Reused: r.pc.isReused(), // 再利用接続か
            }

            // r.idleAt = 割り当てた接続がアイドルだった最終時刻
            if !r.idleAt.IsZero() {
                info.WasIdle = true                  // アイドルから割り当てた接続か (true)
                info.IdleTime = time.Since(r.idleAt) // r.idleAtからの経過時間
            }

            // リクエストにどの接続が割り当てられたか、をユーザに通知するコールバック呼び出し
            trace.GotConn(info)
        }

        // r.err = 失敗時のエラー
        if r.err != nil {
            select {
            case <-treq.ctx.Done(): // 同時にリクエストがキャンセルされていた場合、キャンセルが原因のエラー
                err := context.Cause(treq.ctx)

                if err == errRequestCanceled {
                    err = errRequestCanceledConn
                }

                return nil, err
            default:
                // return below
            }
        }
        return r.pc, r.err

    case <-treq.ctx.Done(): // キャンセル待ち
        err := context.Cause(treq.ctx)
        if err == errRequestCanceled {
            err = errRequestCanceledConn
        }
        return nil, err // w.resultが届く前にコンテキストがDoneになった場合、即座にキャンセルエラーを返す
    }
}
```

## `queueForDial`

```go
// go/src/net/http/transport.go

// if delivered := t.queueForIdleConn(w); // 接続プールから即時に割り当てられる接続を取得
//    !delivered { // 接続がない場合は新規ダイヤルの待機列にwantConnを追加
//     t.queueForDial(w)
// }

func (t *Transport) queueForDial(w *wantConn) {
    w.beforeDial() // テスト用のフック

    // ホストごとの接続と待機列を守るロック
    t.connsPerHostMu.Lock()
    defer t.connsPerHostMu.Unlock()

    // 接続の上限が未設定ならダイヤルを開始
    if t.MaxConnsPerHost <= 0 {
        // ロックを保持したままこのwantConnのためのダイヤルゴルーチンを起動、結果はwantConn.resultに届く
        t.startDialConnForLocked(w)
        return
    }

    // 接続の上限があり、前時点で上限以下の場合
    // n = このホストの接続総数
    if n := t.connsPerHost[w.key];
       n < t.MaxConnsPerHost {
        if t.connsPerHost == nil {
            t.connsPerHost = make(map[connectMethodKey]int) // 初期化
        }

        t.connsPerHost[w.key] = n + 1 // 接続数カウンタをインクリメント
        t.startDialConnForLocked(w)   // ダイヤルを開始
        return
    }

    // ここに到達した時点で接続数の上限がいっぱいになっている状況

    // t.connsPerHostWait = ホストキーごとの待機キュー
    if t.connsPerHostWait == nil {
        t.connsPerHostWait = make(map[connectMethodKey]wantConnQueue) // 初期化
    }

    q := t.connsPerHostWait[w.key] // キューを取得
    q.cleanFrontNotWaiting()       // キューの先頭のキャンセル済みエントリを削除
    q.pushBack(w)                  // wを待機列の末尾に追加する
    t.connsPerHostWait[w.key] = q
}
```

## `startDialConnForLocked`

```go
// (go/src/net/http/transport.go)

// if n := t.connsPerHost[w.key];
//    n < t.MaxConnsPerHost {
//     if t.connsPerHost == nil {
//         t.connsPerHost = make(map[connectMethodKey]int) // 初期化
//     }
//
//     t.connsPerHost[w.key] = n + 1 // 接続数カウンタをインクリメント
//     t.startDialConnForLocked(w)   // ダイヤルを開始
//     return
// }

// このwantConnで新規ダイヤルを開始する
// 呼び出し側がconnsPerHostMuを保持している前提で実行される
func (t *Transport) startDialConnForLocked(w *wantConn) {
    // t.dialsInProgress = ダイヤル中のwantConnのキュー
    t.dialsInProgress.cleanFrontCanceled() // 先頭のキャンセル済みwantConnエントリを削除
    t.dialsInProgress.pushBack(w)          // wを待機列の末尾に追加する

    go func() {
        // TCP/TLSの接続を行い、結果を通知する
        t.dialConnFor(w)

        // 不要になったcancelCtxを無効化する
        t.connsPerHostMu.Lock()
        defer t.connsPerHostMu.Unlock()
        w.cancelCtx = nil
    }()
}
```

## `dialConnFor`

```go
// go/src/net/http/transport.go

// t.dialConnFor(w) (go/src/net/http/transport.go)

func (t *Transport) dialConnFor(w *wantConn) {
    defer w.afterDial() // テスト用フック

    ctx := w.getCtxForDial() // ダイヤルに使用するコンテキストを取得

    if ctx == nil { // キャンセル等でこのwantConnが不要になっている場合など
        t.decConnsPerHost(w.key) // 接続カウンタをデクリメント
        return
    }

    // 接続を開始~確立
    // pc *persistConn = 物理接続ハンドラ
    pc, err := t.dialConn(ctx, w.cm)

    // 接続またはエラーを待ち手へ届ける
    // delivered = 届いたかどうか
    delivered := w.tryDeliver(pc, err, time.Time{})

    if err == nil && // ダイヤルに成功
       (!delivered || pc.alt != nil) { // 未配達 || HTTP/2接続
        t.putOrCloseIdleConn(pc) // 当該接続を接続アイドルプールに追加
    }

    if err != nil { // ダイヤルに失敗
        t.decConnsPerHost(w.key) // 総接続カウントを減らす
    }
}
```

## `dialConn`

```go
// (go/src/net/http/transport.go)

// ctx = 当該TCP/TLSダイヤル処理のキャンセル管理に使用するコンテキスト
// w.com = connectMethod
// pc, err := t.dialConn(ctx, w.cm) (go/src/net/http/transport.go)

func (t *Transport) dialConn(ctx context.Context, cm connectMethod) (pconn *persistConn, err error) {
    // persistConn = 確立済みの一つのTCP/TLS接続をラップした構造体
    // readLoop    = レスポンスを読み込むためのループ (HTTP/1用)
    // writeLoop   = リクエストを書き込むためのループ (HTTP/1用)
    pconn = &persistConn{
        t:        t,        // この接続が属するTransportへの参照
        cacheKey: cm.key(), // 接続プールに対してこの接続を出し入れする際のキー

        // この接続で次に処理すべきリクエスト情報 (レスポンスを誰に返すか) をreadLoopに渡すためのキュー
        reqch: make(chan requestAndChan, 1),

        // ソケットに書き込むリクエストをwriteLoopに渡すためのキュー
        writech: make(chan writeRequest, 1),

        closech:       make(chan struct{}), // 接続のクローズ通知用
        writeErrCh:    make(chan error, 1), // 書き込み側で起きたエラー通知用
        writeLoopDone: make(chan struct{}), // 書き込みループの終了通知用
    }

    trace := httptrace.ContextClientTrace(ctx) // コンテキストに埋め込まれた*httptrace.ClientTraceを取得

    // 発生した接続エラーその状況に応じてラップする関数wrapErr
    wrapErr := func(err error) error {
        if cm.proxyURL != nil {
            // Return a typed error, per Issue 16997
            return &net.OpError{Op: "proxyconnect", Net: "tcp", Err: err}
        }
        return err
    }

    // 以下、プロキシ・オリジンを問わず最初に接続する相手に対する処理

    // 接続先のスキームがhttpsかつTransportにユーザ定義のカスタムTLSダイヤラ (DialTLSContext) が設定されている
    if cm.scheme() == "https" && t.hasCustomTLSDialer() {
        // 以下、TCP / TLSを一気に張る

        var err error

        // customDialTLS = ユーザが指定したカスタムダイヤラを呼び出す
        // ctx = タイムアウトやキャンセルを伝えるコンテキスト (通常はリクエストのContext())
        // cm.addr() = 宛先の"host:port"
        // pconn.conn  = ネットワーク接続
        pconn.conn, err = t.customDialTLS(ctx, "tcp", cm.addr())

        if err != nil {
            return nil, wrapErr(err)
        }

        // tc = pconn.connをTLSセッションを扱うtls.Connにキャスト
        if tc, ok := pconn.conn.(*tls.Conn); // 返ってきたコネクションが*tls.Connかどうか
           ok {
            if trace != nil && trace.TLSHandshakeStart != nil {
                trace.TLSHandshakeStart() // TLSハンドシェイク開始を記録
            }

            if err := tc.HandshakeContext(ctx); // ハンドシェイクを明示的に開始
               err != nil {
                go pconn.conn.Close()

                if trace != nil && trace.TLSHandshakeDone != nil {
                    trace.TLSHandshakeDone(tls.ConnectionState{}, err) // ハンドシェイク終了を記録
                }

                return nil, err
            }

            // ConnectionState = ピア証明書、ALPN結果、暗号スイート等
            cs := tc.ConnectionState()

            if trace != nil && trace.TLSHandshakeDone != nil {
                trace.TLSHandshakeDone(cs, nil)
            }

            // ConnectionStateをpconn.tlsState に保存
            pconn.tlsState = &cs
        }
    } else {
        // 以下、TCPを張る。接続先のスキームがhttpsの場合のみTLSを張る

        conn, err := t.dial(ctx, "tcp", cm.addr()) // TCPを張る。接続先がプロキシかオリジンかはcm.addr()次第

        if err != nil {
            return nil, wrapErr(err)
        }

        pconn.conn = conn

        if cm.scheme() == "https" { // 接続先のスキームがhttps
            var firstTLSHost string

            // firstTLSHost = ホスト名
            if firstTLSHost, _, err = net.SplitHostPort(cm.addr()); // "host:port"をホスト名とポート番号に分割
               err != nil {
                return nil, wrapErr(err)
            }

            // TLSを張る
            if err = pconn.addTLS(ctx, firstTLSHost, trace);
               err != nil {
                return nil, wrapErr(err)
            }
        }
    }

    // ここまででプロキシ or オリジンに対してTLSまたはTCPで接続済み

    // 以下プロキシのセットアップ
    switch {

    // プロキシを利用せず直接クライアントからオリジンにTLSで接続済みの場合
    case cm.proxyURL == nil:
        // Do nothing. Not using a proxy.

    // クライアント<->プロキシ間をTCP接続済み、TCPの上からSOCKS5 / SOCKS5Hを利用して接続する場合
    // (プロキシ <-> オリジン間のプロトコルはcm.targetSchemeで指定)
    case cm.proxyURL.Scheme == "socks5" || cm.proxyURL.Scheme == "socks5h":
        conn := pconn.conn // プロキシへのTCP接続
        d := socksNewDialer("tcp", conn.RemoteAddr().String()) // SOCKS5ダイヤラを作成

        // 以下認証設定
        if u := cm.proxyURL.User; u != nil {
            auth := &socksUsernamePassword{
                Username: u.Username(),
            }
            auth.Password, _ = u.Password()

            d.AuthMethods = []socksAuthMethod{
                socksAuthMethodNotRequired,
                socksAuthMethodUsernamePassword,
            }
            d.Authenticate = auth.Authenticate
        }

        // プロキシへのSOCKS5接続を実施
        if _, err := d.DialWithConn(ctx, conn, "tcp", cm.targetAddr); err != nil {
            conn.Close()
            return nil, err
        }

    // クライアント<->プロキシ間をTCP or TLS接続済み、プロキシ<->オリジン間をHTTPで接続する場合
    case cm.targetScheme == "http":
        pconn.isProxy = true // trueをセットするとリクエストラインにパスではなくURLを記載する

        // プロキシのURLに認証情報が含まれていた場合
        if pa := cm.proxyAuth(); pa != "" {
            pconn.mutateHeaderFunc = func(h Header) { // リクエストヘッダを書き換える関数
                h.Set("Proxy-Authorization", pa)
            }
        }

    // クライアント<->プロキシ間をTCP or TLS接続済み、プロキシ<->オリジン間をHTTPSで接続する場合
    case cm.targetScheme == "https":
        conn := pconn.conn
        var hdr Header

        // CONNECT用にヘッダを追加する
        if t.GetProxyConnectHeader != nil {
            var err error
            hdr, err = t.GetProxyConnectHeader(ctx, cm.proxyURL, cm.targetAddr)
            if err != nil {
                conn.Close()
                return nil, err
            }
        } else {
            hdr = t.ProxyConnectHeader
        }

        if hdr == nil {
            hdr = make(Header)
        }

        // プロキシ認証の付与
        if pa := cm.proxyAuth(); pa != "" {
            hdr = hdr.Clone()
            hdr.Set("Proxy-Authorization", pa)
        }

        // CONNECTリクエストを作成
        connectReq := &Request{
            Method: "CONNECT",
            URL:    &url.URL{Opaque: cm.targetAddr},
            Host:   cm.targetAddr,
            Header: hdr,
        }

        // 1分でタイムアウトするCONNECT用のコンテキストを作成
        connectCtx, cancel := testHookProxyConnectTimeout(ctx, 1*time.Minute)
        defer cancel()

        // バックグラウンドで実行するgoroutineの完了通知用のチャネルを作成
        didReadResponse := make(chan struct{}) // closed after CONNECT write+read is done or fails

        var (
            resp *Response
            err  error // write or read error
        )

        // goroutineを起動
        go func() {
            defer close(didReadResponse)

            // プロキシに対してCONNECTリクエストを送る
            err = connectReq.Write(conn)
            if err != nil { return }

            // プロキシからのレスポンスヘッダを読み込む
            br := bufio.NewReader(&io.LimitedReader{R: conn, N: t.maxHeaderResponseSize()})
            resp, err = ReadResponse(br, connectReq)
        }()

        // CONNECTリクエストの結果を待つ
        select {
        case <-connectCtx.Done(): // connectCtxがタイムアウト
            conn.Close()
            <-didReadResponse
            return nil, connectCtx.Err()
        case <-didReadResponse: // CONNECTリクエストを送信、レスポンス受信して読み終えることに成功
            // resp or err now set
        }

        if err != nil {
            conn.Close()
            return nil, err
        }

        if t.OnProxyConnectResponse != nil {
            // Transport.OnProxyConnectResponse = ユーザー定義のコールバック
            // ctx = 実行中のコンテキスト
            // cm.proxyURL = 接続先プロキシのURL
            // connectReq = CONNECTリクエストの内容
            // resp = プロキシからのレスポンスの内容
            err = t.OnProxyConnectResponse(ctx, cm.proxyURL, connectReq, resp)

            if err != nil {
                conn.Close()
                return nil, err
            }
        }

        // CONNECTのレスポンスが200以外だった場合
        if resp.StatusCode != 200 {
            _, text, ok := strings.Cut(resp.Status, " ")
            conn.Close()

            if !ok {
                return nil, errors.New("unknown status code")
            }

            return nil, errors.New(text)
        }
    }

    // プロキシがある場合、ここまでの処理で以下の状態になっているはず
    // case cm.proxyURL.Scheme == "socks5" || cm.proxyURL.Scheme == "socks5h":
    //   - クライアント<->プロキシ間: SOCKS5接続済み
    //   - プロキシ<->オリジン間: TCP接続済み (SOCKS5のCONNECTコマンドでトンネルが確立)
    // case cm.targetScheme == "http":
    //   - クライアント<->プロキシ間: HTTP接続済み
    //   - プロキシ<->オリジン間: 接続なし (必要時にプロキシがオリジンへTCPを張る)
    // case cm.targetScheme == "https":
    //   - クライアント<->プロキシ間: HTTP接続済み
    //   - プロキシ<->オリジン間: TCPで接続済み (CONNECTリクエストを実行)

    // プロキシあり && プロキシ<->オリジン間をHTTPSで接続する場合
    if cm.proxyURL != nil && cm.targetScheme == "https" {
        // プロキシ<->オリジン間でTLSを張る
        if err := pconn.addTLS(ctx, cm.tlsHost(), trace); err != nil {
            return nil, err
        }
    }

    // 以下、暗号化なしのh2cを事前知識ありで使用する場合
    unencryptedHTTP2 := pconn.tlsState == nil && // まだTLSを張っていない
        t.Protocols != nil && t.Protocols.UnencryptedHTTP2() && // HTTP/2を暗号化せずに使用
        !t.Protocols.HTTP1() // HTTP/1 を使わない

    if unencryptedHTTP2 {
        next, ok := t.TLSNextProto[nextProtoUnencryptedHTTP2] // h2c用のエントリを取得
        if !ok {
            return nil, errors.New("http: Transport does not support unencrypted HTTP/2")
        }

        // alt = HTTP/1の処理をバイパスして別のプロトコルで処理するRoundTripper
        alt := next(cm.targetAddr, unencryptedTLSConn(pconn.conn))

        // h2側の初期化で致命的に失敗した場合のエラー処理
        if e, ok := alt.(erringRoundTripper); ok {
            // pconn.conn was closed by next (http2configureTransports.upgradeFn).
            return nil, e.RoundTripErr()
        }

        return &persistConn{t: t, cacheKey: pconn.cacheKey, alt: alt}, nil
    }

    // 以下TLS + HTTP/2で接続する場合
    // HTTP/2の実装はh2_bundle.go
    if s := pconn.tlsState; // TLSの接続情報を取得
       s != nil &&
       s.NegotiatedProtocolIsMutual && // ALPNがサーバと合意できた
       s.NegotiatedProtocol != "" {

        if next, ok := t.TLSNextProto[s.NegotiatedProtocol]; ok {
            // alt = HTTP/1の処理をバイパスして別のプロトコルで処理するRoundTripper
            alt := next(cm.targetAddr, pconn.conn.(*tls.Conn))

            if e, ok := alt.(erringRoundTripper); ok {
                return nil, e.RoundTripErr()
            }

            return &persistConn{t: t, cacheKey: pconn.cacheKey, alt: alt}, nil
        }
    }

    // 以下はHTTP/1で接続する場合
    pconn.br = bufio.NewReaderSize(pconn, t.readBufferSize())
    pconn.bw = bufio.NewWriterSize(persistConnWriter{pconn}, t.writeBufferSize())

    go pconn.readLoop()  // レスポンスをリクエストに対応付けて受け取り、呼び出し側へ返す
    go pconn.writeLoop() // リクエストをシリアライズして送出
    return pconn, nil
}
```

## `addTLS`

```go
// (go/src/net/http/transport.go)

func (pconn *persistConn) addTLS(
    ctx context.Context,
    name string,
    trace *httptrace.ClientTrace
) error {
    cfg := cloneTLSConfig(pconn.t.TLSClientConfig) // Transport.TLSClientConfigをコピー

    if cfg.ServerName == "" { // ServerNameが未設定の場合
        cfg.ServerName = name
    }

    if pconn.cacheKey.onlyH1 { // HTTP/1の場合
        cfg.NextProtos = nil // ALPN でHTTP/2を広告しない
    }

    plainConn := pconn.conn // すでに接続済みのTCP接続
    tlsConn := tls.Client(plainConn, cfg) // ...を、ラップするTLS コネクションオブジェクトをつくる

    errc := make(chan error, 2)
    var timer *time.Timer // for canceling TLS handshake

    if d := pconn.t.TLSHandshakeTimeout;
       d != 0 {
        timer = time.AfterFunc(d, func() {
            errc <- tlsHandshakeTimeoutError{}
        })
    }

    // 別goroutineTLSハンドシェイクを開始
    go func() {
        if trace != nil && trace.TLSHandshakeStart != nil {
            trace.TLSHandshakeStart()
        }

        // ALPNネゴシエーションを実施
        err := tlsConn.HandshakeContext(ctx)

        if timer != nil {
            timer.Stop()
        }
        errc <- err
    }()

    if err := <-errc; // 最初に届いたエラーを取得
       err != nil {
        plainConn.Close() // TCP接続をクローズ

        if err == (tlsHandshakeTimeoutError{}) {
            // Now that we have closed the connection,
            // wait for the call to HandshakeContext to return.
            <-errc
        }

        if trace != nil && trace.TLSHandshakeDone != nil {
            trace.TLSHandshakeDone(tls.ConnectionState{}, err)
        }
        return err
    }

    // ConnectionStateを取得
    cs := tlsConn.ConnectionState()

    if trace != nil && trace.TLSHandshakeDone != nil {
        trace.TLSHandshakeDone(cs, nil)
    }

    // ConnectionStateをpersistConn.tlsState に保存
    pconn.tlsState = &cs
    // persistConn.connをTLS接続に差し替え
    pconn.conn = tlsConn
    return nil
}
```

## `HandshakeContext`

```go
// (go/src/crypto/tls/conn.go)

func (c *Conn) HandshakeContext(ctx context.Context) error {
    return c.handshakeContext(ctx)
}

func (c *Conn) handshakeContext(ctx context.Context) (ret error) {
    // 現在進行中のハンドシェイクがある場合
    if c.isHandshakeComplete.Load() {
        return nil
    }

    // handshakeCtx = 以降のハンドシェイク処理に渡される、このハンドシェイク専用のコンテキスト
    handshakeCtx, cancel := context.WithCancel(ctx)

    defer cancel()

    // -- ハンドシェイク処理をコンテキストキャンセルで中断できるようにする準備 --

    if c.quic != nil { // QUICの場合
        // QUIC側の構造体にhandshakeCtx.Doneチャネルとキャンセル関数cancelを渡す
        c.quic.cancelc = handshakeCtx.Done()
        c.quic.cancel = cancel

    } else if ctx.Done() != nil { // QUICではない、かつこのコンテキストがキャンセルorタイムアウト可能な場合
        done := make(chan struct{})         // 関数の終了を通知するチャネルを作成
        interruptRes := make(chan error, 1) // 中断が発生したかどうかを通知するチャネルを作成

        // 終了時にdoneを閉じ、キャンセル発生時にinterrupterからのその内容を受け取ってretに保存
        defer func() {
            close(done)

            if ctxErr := <-interruptRes;
               ctxErr != nil {
                ret = ctxErr
            }
        }()

        go func() {
            select {
            case <-handshakeCtx.Done(): // ハンドシェイク完了前にキャンセルorタイムアウトした
                _ = c.conn.Close() // 接続をクローズ
                interruptRes <- handshakeCtx.Err() // キャンセル発生時にそれをエラーとして保存
            case <-done: // ハンドシェイクが正常に完了した
                interruptRes <- nil
            }
        }()
    }

    // 同じ*tls.Conn に対して複数のgoroutineが同時にハンドシェイクを開始しないようにロック
    c.handshakeMutex.Lock()
    defer c.handshakeMutex.Unlock()

    // 前回のハンドシェイクで発生したエラーがある場合
    if err := c.handshakeErr; err != nil {
        return err
    }
    // 先行するgoroutineがすでにハンドシェイクを完了させている場合に備えて、ロック取得後にもチェックする
    if c.isHandshakeComplete.Load() {
        return nil
    }

    // c.in = TLSレコード層の入力パスを守るミューテックス
    c.in.Lock()
    defer c.in.Unlock()

    // -- ハンドシェイクの実行 --
    c.handshakeErr = c.handshakeFn(handshakeCtx)

    // handshakeFnはtype Conn structのメンバとして保持されているハンドシェイク用の関数
    // handshakeFn func(context.Context) error // (*Conn).clientHandshake or serverHandshake
    // src/crypto/tls/conn.goのfunc Clientで以下のようにセットされる
    //
    // (src/crypto/tls/conn.go)
    // func Client(conn net.Conn, config *Config) *Conn {
    //     c := &Conn{
    //         conn:     conn,
    //         config:   config,
    //         isClient: true,
    //     }
    //     c.handshakeFn = c.clientHandshake
    //     return c
    // }

    if c.handshakeErr == nil {
        c.handshakes++ // この接続でハンドシェイクが成功した回数を記録
    } else {
        // ハンドシェイク中にエラーが起きると、TLS仕様上はAlert レコードを送信する必要がある
        c.flush() // 書き込みバッファに残っている可能性がある未送出のアラートをフラッシュする
    }

    if c.handshakeErr == nil && !c.isHandshakeComplete.Load() {
        c.handshakeErr = errors.New("tls: internal error: handshake should have had a result")
    }
    if c.handshakeErr != nil && c.isHandshakeComplete.Load() {
        panic("tls: internal error: handshake returned an error but is marked successful")
    }

    if c.quic != nil {
        if c.handshakeErr == nil {
            c.quicHandshakeComplete()
            // Provide the 1-RTT read secret now that the handshake is complete.
            // The QUIC layer MUST NOT decrypt 1-RTT packets prior to completing
            // the handshake (RFC 9001, Section 5.7).
            c.quicSetReadSecret(QUICEncryptionLevelApplication, c.cipherSuite, c.in.trafficSecret)
        } else {
            var a alert
            c.out.Lock()
            if !errors.As(c.out.err, &a) {
                a = alertInternalError
            }
            c.out.Unlock()
            // Return an error which wraps both the handshake error and
            // any alert error we may have sent, or alertInternalError
            // if we didn't send an alert.
            // Truncate the text of the alert to 0 characters.
            c.handshakeErr = fmt.Errorf("%w%.0w", c.handshakeErr, AlertError(a))
        }
        close(c.quic.blockedc)
        close(c.quic.signalc)
    }

    return c.handshakeErr
}
```

## `clientHandshake`

```
// (src/crypto/tls/handshake_client.go)

func (c *Conn) clientHandshake(ctx context.Context) (err error) {
    // configをセット
    // configは暗号スイート、証明書、セッションを管理する値など
    if c.config == nil {
        c.config = defaultConfig()
    }

    c.didResume = false // didResume = セッション再開に成功したかどうか
    c.curveID = 0 // 椭円曲線のID

    // ClientHelloレコードを作成
    //   hello        = ClientHelloレコード
    //   keyShareKeys = Key Share拡張のクライアント側秘密鍵群
    //   ech          = Encrypted ClientHello (ECH) 用の付帯情報
    hello, keyShareKeys, ech, err := c.makeClientHello()

    if err != nil {
        return err
    }

    // セッション再開 / 0-RTTの準備
    // loadSession = 直近のセッション情報ClientHelloに折り込み、再開できるかを判定する
    //   session     = 再開できるセッションの候補
    //   earlySecret = 0-RTT用の派生シークレット
    //   binderKey   = PSK binderの鍵
    session, earlySecret, binderKey, err := c.loadSession(hello)

    if err != nil {
        return err
    }

    // セッション再開を試みて失敗した場合、PSKをキャッシュから捨てる
    if session != nil {
        defer func() {
            if err != nil {
                if cacheKey := c.clientSessionCacheKey(); cacheKey != "" {
                    c.config.ClientSessionCache.Put(cacheKey, nil)
                }
            }
        }()
    }

    // makeClientHello() がECHを試すための材料を返した場合
    if ech != nil {
        // outer / innerの2種類のClientHelloを扱う

        ech.innerHello = hello.clone() // innerHelloに暗号化して送信する内容をセット

        // outerHello (平文) のClientHello.serverNameを公開用のホスト名に置き換える
        hello.serverName = string(ech.config.PublicName)

        // outerHelloのrandomを新規生成
        hello.random = make([]byte, 32)
        _, err = io.ReadFull(c.config.rand(), hello.random)

        if err != nil {
            return errors.New("tls: short read from Rand: " + err.Error())
        }

        // outerHelloにECH拡張を生成して付与
        if err := computeAndUpdateOuterECHExtension(hello, ech.innerHello, ech, true); err != nil {
            return err
        }
    }

    // 以降のサーバ証明書検証で使用するSNIの設定
    c.serverName = hello.serverName

    // ClientHelloをnet.Connに書き込む
    if _, err := c.writeHandshakeRecord(hello, nil); err != nil {
        return err
    }

    // QUIC向け
    if hello.earlyData { // 当該接続を再開し、0-RTTを試みる
        suite := cipherSuiteTLS13ByID(session.cipherSuite)
        transcript := suite.hash.New()

        if err := transcriptMsg(hello, transcript); err != nil {
            return err
        }

        earlyTrafficSecret := earlySecret.ClientEarlyTrafficSecret(transcript)

        // Early Data用の送信用鍵をセット
        c.quicSetWriteSecret(QUICEncryptionLevelEarly, suite.id, earlyTrafficSecret)
    }

    // サーバからメッセージ (暗号化前なので平文) を受信
    msg, err := c.readHandshake(nil)

    if err != nil {
        return err
    }

    // 受信したメッセージがServerHelloであることを確認
    serverHello, ok := msg.(*serverHelloMsg)
    if !ok {
        c.sendAlert(alertUnexpectedMessage)
        return unexpectedMessageError(serverHello, msg)
    }

    // ServerHelloをもとに実際に使うTLSのバージョンを確定
    if err := c.pickTLSVersion(serverHello); err != nil {
        return err
    }

    // ダウングレードの検知
    // クライアント側が対応可能な最大バージョンを取得
    maxVers := c.config.maxSupportedVersion(roleClient)
    // tls12Downgrade = TLS1.2用のカナリア (TLS1.3対応サーバがTLS1.2を返すときに埋める値)
    tls12Downgrade := string(serverHello.random[24:]) == downgradeCanaryTLS12
    // tls11Downgrade = TLS1.1用のカナリア (TLS1.2対応サーバがTLS1.1を返すときに埋める値)
    tls11Downgrade := string(serverHello.random[24:]) == downgradeCanaryTLS11

    // ダウングレード (MITMによるバージョンの変更や中間機器の故障) を検知した場合はエラー
    if maxVers == VersionTLS13 && c.vers <= VersionTLS12 && (tls12Downgrade || tls11Downgrade) ||
        maxVers == VersionTLS12 && c.vers <= VersionTLS11 && tls11Downgrade {
        c.sendAlert(alertIllegalParameter)
        return errors.New("tls: downgrade attempt detected, possibly due to a MitM attack or a broken middlebox")
    }

    // TLS1.3を利用する場合はclientHandshakeStateTLS13構造体を作成し、TLS1.3としてハンドシェイクを実施
    if c.vers == VersionTLS13 {
        hs := &clientHandshakeStateTLS13{
            c:            c,
            ctx:          ctx,
            serverHello:  serverHello,
            hello:        hello,
            keyShareKeys: keyShareKeys,
            session:      session,
            earlySecret:  earlySecret,
            binderKey:    binderKey,
            echContext:   ech,
        }
        return hs.handshake()
    }

    // TLS1.2/1.1利用する場合はclientHandshakeState構造体を作成し、ハンドシェイクを実施
    hs := &clientHandshakeState{
        c:           c,
        ctx:         ctx,
        serverHello: serverHello,
        hello:       hello,
        session:     session,
    }
    return hs.handshake()
}
```

## `RoundTrip`

```go
// (src/net/http/h2_bundle.go)

// 標準的なHTTP/2トランスポート
func (t *http2Transport) RoundTrip(req *Request) (*Response, error) {
    return t.RoundTripOpt(req, http2RoundTripOpt{})
}

// 暗号化なしのHTTP/2トランスポート
func (t *http2unencryptedTransport) RoundTrip(req *Request) (*Response, error) {
    return (*http2Transport)(t).RoundTripOpt(req, http2RoundTripOpt{allowHTTP: true})
}

func (t *http2Transport) RoundTripOpt(req *Request, opt http2RoundTripOpt) (*Response, error) {
    // リクエストURLのスキームとプロトコルの不整合を検証
    switch req.URL.Scheme {
    case "https":
        // Always okay.
    case "http":
        if !t.AllowHTTP && !opt.allowHTTP {
            return nil, errors.New("http2: unencrypted HTTP/2 not enabled")
        }
    default:
        return nil, errors.New("http2: unsupported scheme")
    }

    // addr = リクエスト先を表す"scheme://host:port"形式の文字列
    addr := http2authorityAddr(req.URL.Scheme, req.URL.Host)

    // retryをインクリメントしながら接続の取得および(再)送信を行う
    for retry := 0; ; retry++ {
        // 接続プールからhttp2ClientConnを取得
        cc, err := t.connPool().GetClientConn(req, addr)

        if err != nil {
            t.vlogf("http2: Transport failed to get client conn for %s: %v", addr, err)
            return nil, err
        }

        // cc.atomicReused = このhttp2ClientConnが過去にリクエストの送信に使用されたかどうか
        reused := !atomic.CompareAndSwapUint32(&cc.atomicReused, 0, 1)

        // トレースを発火させる
        http2traceGotConn(req, cc, reused)

        // HTTP/2のストリームを開始。リクエストを送信
        res, err := cc.RoundTrip(req)

        if err != nil && retry <= 6 { // 最大7回までリトライする
            roundTripErr := err

            // http2shouldRetryRequest = 再送可能なエラーかどうか
            if req, err = http2shouldRetryRequest(req, err);
               err == nil {
                // 初回は即時再送
                if retry == 0 {
                    t.vlogf("RoundTrip retrying after failure: %v", roundTripErr)
                    continue
                }

                // 2回目以降は指数関数バックオフで再送
                backoff := float64(uint(1) << (uint(retry) - 1))
                backoff += backoff * (0.1 * mathrand.Float64())
                d := time.Second * time.Duration(backoff)
                tm := t.newTimer(d)

                select {
                case <-tm.C():
                    t.vlogf("RoundTrip retrying after failure: %v", roundTripErr)
                    continue
                case <-req.Context().Done():
                    tm.Stop()
                    err = req.Context().Err()
                }
            }
        }

        // 初回リクエスト、かつ接続がクローズしていた場合
        if err == http2errClientConnNotEstablished {
            if cc.idleTimer != nil {
                cc.idleTimer.Stop()
            }
            t.connPool().MarkDead(cc) // 接続プールから除外
        }

        if err != nil {
            t.vlogf("RoundTrip failure: %v", err)
            return nil, err
        }

        return res, nil
    }
}
```

```go
// (src/net/http/h2_bundle.go)

// res, err := cc.RoundTrip(req)

func (cc *http2ClientConn) RoundTrip(req *Request) (*Response, error) {
    return cc.roundTrip(req, nil)
}

func (cc *http2ClientConn) roundTrip(req *Request, streamf func(*http2clientStream)) (*Response, error) {
    ctx := req.Context()

    cs := &http2clientStream{ // ストリーム (roundtripが呼ばれるたびに新規作成される)
        cc:                   cc, // 利用するHTTP/2接続
        ctx:                  ctx, // リクエストのContext
        reqCancel:            req.Cancel, // 互換性用
        isHead:               req.Method == "HEAD", // HEADメソッドかどうか (= ボディを読む必要があるかどうか)
        reqBody:              req.Body, // リクエストボディ
        reqBodyContentLength: http2actualContentLength(req), // 送信サイズ
        trace:                httptrace.ContextClientTrace(ctx), // httptraceのコールバック一式
        peerClosed:           make(chan struct{}), // 送信先がストリームを閉じた場合に通知されるチャネル
        abort:                make(chan struct{}), // 自らがこのストリームを中止したいときに通知するチャネル
        respHeaderRecv:       make(chan struct{}), // 自らがレスポンスヘッダを受信完了したときに通知するチャネル
        donec:                make(chan struct{}), // ストリームの全処理が完了したときに通知するチャネル
    }

    // このリクエストに対するレスポンスとしてgzip圧縮ファイルを受け入れるかどうか
    cs.requestedGzip = httpcommon.IsRequestGzip(req.Method, req.Header, cc.t.disableCompression())

    // 別goroutineでリクエストの送信処理を開始
    go cs.doRequest(req, streamf)

    // ストリームの完了を待機
    waitDone := func() error {
        select {
        case <-cs.donec:     // このストリームの処理が完了したとき
            return nil
        case <-ctx.Done():   // Contextのキャンセルまたはタイムアウトしたとき
            return ctx.Err()
        case <-cs.reqCancel: // キャンセル発生時 (互換性用)
            return http2errRequestCanceled
        }
    }

    // レスポンスヘッダを受信後に実行する関数
    handleResponseHeaders := func() (*Response, error) {
        // レスポンスを取得
        res := cs.res

        // ステータスコード3xx/4xx/5xxの場合、リクエストボディの送信を中止する
        if res.StatusCode > 299 {
            cs.abortRequestBodyWrite()
        }

        res.Request = req // 対応する元リクエストを取得
        res.TLS = cc.tlsState // この接続のTLSの状態を取得

        // レスポンスボディとリクエストボディが何もない場合、
        // waitDone = ストリームの終了 (END_STREAM) を待つ
        if res.Body == http2noBody && http2actualContentLength(req) == 0 {
            if err := waitDone(); err != nil {
                return nil, err
            }
        }

         // レスポンスを返す
        return res, nil
    }

    // ストリームを中断する際に実行する関数
    cancelRequest := func(cs *http2clientStream, err error) error {
        cs.cc.mu.Lock()
        // cs.reqBodyClosed = このリクエストボディをクローズ後に通知されるチャネルを取得
        bodyClosed := cs.reqBodyClosed
        cs.cc.mu.Unlock()

        if bodyClosed != nil {
            // チャネルが閉じるまで待つ
            <-bodyClosed
        }
        return err
    }

    for {
        select {

        // レスポンスのHEADERSを受信した場合
        case <-cs.respHeaderRecv:
            return handleResponseHeaders()

        // ストリームを中止する場合
        case <-cs.abort:
            select {
            case <-cs.respHeaderRecv: // ヘッダを受信済みの場合
                return handleResponseHeaders()
            default:
                waitDone()
                return nil, cs.abortErr
            }

        // Contextがキャンセルされた場合
        case <-ctx.Done():
            err := ctx.Err()
            cs.abortStream(err)
            return nil, cancelRequest(cs, err)

        // リクエストがキャンセルされた場合 (互換性用)
        case <-cs.reqCancel:
            cs.abortStream(http2errRequestCanceled)
            return nil, cancelRequest(cs, http2errRequestCanceled)
        }
    }
}
```

## `doRequest`

```go
// (src/net/http/h2_bundle.go)

func (cs *http2clientStream) doRequest(req *Request, streamf func(*http2clientStream)) {
    cs.cc.t.markNewGoroutine() // 起動した送信系ゴルーチンの数を追跡するためのフック
    err := cs.writeRequest(req, streamf) // リクエスト送信処理
    cs.cleanupWriteRequest(err) // 送信側のクリーンアップ
}

func (cs *http2clientStream) writeRequest(req *Request, streamf func(*http2clientStream)) (err error) {
    cc := cs.cc   // HTTP/2接続
    ctx := cs.ctx // リクエストのコンテキスト

    // Extended CONNECT (RFC 8441) の判定
    // :protocol擬似ヘッダが含まれる場合はExtended CONNECT
    var isExtendedConnect bool
    if req.Method == "CONNECT" && req.Header.Get(":protocol") != "" {
        isExtendedConnect = true
    }

    // --- リクエストの送信準備 ---

    // http2ClientConnの初期化をチェック
    if cc.reqHeaderMu == nil {
        panic("RoundTrip on uninitialized ClientConn") // for tests
    }

    // Extended CONNECTの場合
    if isExtendedConnect {
        select {
        case <-cs.reqCancel: // キャンセル発生時 (互換性用)
            return http2errRequestCanceled
        case <-ctx.Done():   // Contextがキャンセルまたはタイムアウトしたとき
            return ctx.Err()
        case <-cc.seenSettingsChan: // SETTINGSフレームを受信したとき
            // extendedConnectAllowed = サーバがENABLE_CONNECT_PROTOCOLを有効化したかどうか
            if !cc.extendedConnectAllowed {
                // サーバがExtended CONNECTをサポートしないのに送ってしまった場合
                return http2errExtendedConnectNotSupported
            }
        }
    }

    // 同一コネクション上でのHEADERSフレームの送信が競合しないようにするためのロック処理
    // cc.reqHeaderMu = バッファ1つのチャネル
    // cc.reqHeaderMuに値を送ること (= ロックを取得する) ができるようになるまで待つ
    // ヘッダ送信が終わった側が<-cc.reqHeaderMuを受信してバッファを開ける
    select {
    case cc.reqHeaderMu <- struct{}{}:
    case <-cs.reqCancel: //キャンセル発生時 (互換性用)
        return http2errRequestCanceled
    case <-ctx.Done(): // Contextがキャンセルまたはタイムアウトしたとき
        return ctx.Err()
    }
    // - HPACKの動的テーブルは同一コネクション内で共有されるため、
    //   競合した場合正しくテーブルへの行の登録・読み出しができない
    // - HEADERSフレームは分割されうるため、サーバ側でHEADERSフレームを受信した後にCONTINUATIONフレームが届かず
    //   別のストリームのHEADERSフレームに割り込まれるとプロトコルエラーになる

    // 接続全体の状態をロック
    cc.mu.Lock()

     // 接続がアイドルになった場合に自動クローズするタイマーを停止
    if cc.idleTimer != nil {
        cc.idleTimer.Stop()
    }

    // ストリームの予約枠を解放する
    // func (cc *http2ClientConn) ReserveNewRequest() boolの中で
    // cc.streamsReserved++したstreamsReservedをデクリメントしている
    cc.decrStreamReservationsLocked()

    // 新しいストリームを開ける状態になるまで待つ
    if err := cc.awaitOpenSlotForStreamLocked(cs);
       err != nil {
        cc.mu.Unlock()
        <-cc.reqHeaderMu
        return err
    }

    // 新しいストリームを作成してhttp2ClientConnに登録し、ストリームIDを割り当てるなどのセットアップを行う
    cc.addStreamLocked(cs) // assigns stream ID

    // 接続を再利用しないリクエストの場合はdoNotReuseフラグを立てる
    if http2isConnectionCloseRequest(req) {
        cc.doNotReuse = true
    }

    // ロックを解除
    cc.mu.Unlock()

    if streamf != nil {
        streamf(cs)
    }

    // リクエストヘッダにExpect: 100-continueがセットされている場合 (ヘッダだけ送信して様子見する場合) の処理
    continueTimeout := cc.t.expectContinueTimeout()
    if continueTimeout != 0 {
        if !httpguts.HeaderValuesContainsToken(req.Header["Expect"], "100-continue") {
            continueTimeout = 0
        } else {
            // サーバからの100 Continueを通知するチャネル (待機時間内に通知がなければボディの送信を始める)
            cs.on100 = make(chan struct{}, 1)
        }
    }

    // --- リクエストを送信 ---

    // 疑似ヘッダ (:method, :scheme, :authority, :path) + 通常のヘッダをHPACKで圧縮し、
    // HEADERS (+ CONTINUATION) フレームとして送信
    err = cs.encodeAndWriteHeaders(req)

    // ヘッダ専用ロックを解放
    <-cc.reqHeaderMu

    if err != nil {
        return err
    }

    // Content-Length == 0の場合
    // (GET/HEADの場合、もしくはPOST/PUTかつContent-Length: 0の場合)
    hasBody := cs.reqBodyContentLength != 0

    if !hasBody {
        // 送信したヘッダにEND_STREAMフラグが立っていたものとみなしてcs.sentEndStream = trueにセット
        cs.sentEndStream = true
    } else { // これから送信するべきボディがある場合はこちら
        if continueTimeout != 0 { // Expect: 100-continueをセットしている場合
            http2traceWait100Continue(cs.trace)
            timer := time.NewTimer(continueTimeout) // 100 Continueを待機するタイマーを起動

            select {
            case <-timer.C: // 100 Continueを受信する前にタイムアウト (-> 最適化を諦めてボディを送信)
                err = nil
            case <-cs.on100: // 100 Continueを受信 (-> ボディを送信)
                err = nil
            case <-cs.abort: // ストリームの送信を中止
                err = cs.abortErr
            case <-ctx.Done(): // Contextのキャンセル
                err = ctx.Err()
            case <-cs.reqCancel: // リクエストのキャンセル (互換性用)
                err = http2errRequestCanceled
            }

            timer.Stop()

            if err != nil {
                http2traceWroteRequest(cs.trace, err)
                return err
            }
        }

        // DATAフレームをフロー制御に従って分割送信
        if err = cs.writeRequestBody(req);
           err != nil {
            if err != http2errStopReqBodyWrite {
                http2traceWroteRequest(cs.trace, err)
                return err
            }
        } else {
            // 「送信済み」を記録
            cs.sentEndStream = true
        }
    }

    http2traceWroteRequest(cs.trace, err)

    // --- レスポンスヘッダの受信を待機 ---

    var respHeaderTimer <-chan time.Time
    var respHeaderRecv chan struct{}

    // レスポンスヘッダが返ってくるまでの最大待ち時間を取得
    if d := cc.responseHeaderTimeout();
       d != 0 { // タイムアウトが有効な場合
        timer := cc.t.newTimer(d) // タイマーを作成
        defer timer.Stop()
        respHeaderTimer = timer.C() // タイムアウトの通知を受け取るチャネル
        respHeaderRecv = cs.respHeaderRecv // レスポンスヘッダの受信を知らせるシグナル
    }

    for {
        select {
        case <-cs.peerClosed: // サーバがこのストリームをクローズ (レスポンス処理が完了 = 成功)
            return nil
        case <-respHeaderTimer: // レスポンスヘッダの待機がタイムアウト
            return http2errTimeout
        case <-respHeaderRecv: // レスポンスヘッダを受信
            respHeaderRecv = nil
            respHeaderTimer = nil // keep waiting for END_STREAM
        case <-cs.abort: // このストリームの送受信を中止
            return cs.abortErr
        case <-ctx.Done(): // Contextのキャンセル
            return ctx.Err()
        case <-cs.reqCancel: // リクエストのキャンセル (互換性用)
            return http2errRequestCanceled
        }
    }
}

func (cs *http2clientStream) encodeAndWriteHeaders(req *Request) error {
    cc := cs.cc
    ctx := cs.ctx

    // ロックを取得 (HEADERS + CONTINUATION... は連続で送信する必要がある)
    cc.wmu.Lock()
    defer cc.wmu.Unlock()

    // ロック獲得までの待機中に 中止/キャンセルが先行している場合は中断
    select {
    case <-cs.abort:
        return cs.abortErr
    case <-ctx.Done():
        return ctx.Err()
    case <-cs.reqCancel:
        return http2errRequestCanceled
    default:
    }

    cc.hbuf.Reset()

    // リクエストヘッダをHPACK圧縮してcc.hbufに保存する
    // 内部でヘッダフィールドを順に生成し、その度にコールバックを呼ぶ
    res, err := http2encodeRequestHeaders(
        // *http.Request
        req,
        // Accept-Encoding: gzip を付けるかどうか
        cs.requestedGzip,
        // 送信先が許容するヘッダのサイズ (SETTINGSで通告されている)
        cc.peerMaxHeaderListSize,
        // ヘッダ名と値を受け取ったらそれをcc.hbufに書き込むコールバック
        func(name, value string) { cc.writeHeader(name, value) }
    )
    if err != nil {
        return fmt.Errorf("http2: %w", err)
    }

    hdrs := cc.hbuf.Bytes()

    endStream := !res.HasBody && !res.HasTrailers
    cs.sentHeaders = true

    // 出来上がったHPACKブロックをHEADERS + CONTINUATION...に分割して送信
    err = cc.writeHeaders(cs.ID, endStream, int(cc.maxFrameSize), hdrs)
    http2traceWroteHeaders(cs.trace)
    return err
}

func http2encodeRequestHeaders(req *Request, addGzipHeader bool, peerMaxHeaderListSize uint64, headerf func(name, value string)) (httpcommon.EncodeHeadersResult, error) {
    // 共通リクエストヘッダをhttpcommon.Requestに詰め替える
    return httpcommon.EncodeHeaders(req.Context(), httpcommon.EncodeHeadersParam{
        Request: httpcommon.Request{
            Header:              req.Header,
            Trailer:             req.Trailer,
            URL:                 req.URL,
            Host:                req.Host,
            Method:              req.Method,
            ActualContentLength: http2actualContentLength(req),
        },
        AddGzipHeader:         addGzipHeader,
        PeerMaxHeaderListSize: peerMaxHeaderListSize,
        DefaultUserAgent:      http2defaultUserAgent,
    }, headerf) // ヘッダ一件ずつに対してheaderfを実行する
}

func (cs *http2clientStream) writeRequestBody(req *Request) (err error) {
    cc := cs.cc        // HTTP/2コネクション
    body := cs.reqBody // リクエストボディのio.Reader
    sentEnd := false   // DATAを最後まで送信したか (END_STREAMフラグを立てたか)

    hasTrailers := req.Trailer != nil    // リクエストトレーラがあるか (あれば別HEADERSフレームで送る)
    remainLen := cs.reqBodyContentLength // 未送信のバイト数
    hasContentLen := remainLen != -1     // Content-Lengthがあるか

    // ロックをとってMAX_FRAME_SIZE (DATAフレームの最大サイズ) を取得 (サーバ側のSETTINGSによって決定)
    cc.mu.Lock()
    maxFrameSize := int(cc.maxFrameSize)
    cc.mu.Unlock()

    // 以下、DATAフレームを書き出す際に使用するバッファを取得する
    scratchLen := cs.frameScratchBufferLen(maxFrameSize)
    var buf []byte
    index := http2bufPoolIndex(scratchLen)

    if bp, ok := http2bufPools[index].Get().(*[]byte); // プールからバッファを取得する
       ok && len(*bp) >= scratchLen {
        defer http2bufPools[index].Put(bp) // 関数を抜ける際にバッファをプールへ返す
        buf = *bp
    } else {
        buf = make([]byte, scratchLen)
        defer http2bufPools[index].Put(&buf)
    }

    // リクエストボディのEOFに到達したかどうか
    var sawEOF bool

    // リクエストボディのEOFに到達するまで読み出す
    for !sawEOF {
        // DATAフレームを書き出すためのバッファにリクエストボディを読み込む
        // n = 読み込んだバイト数
        n, err := body.Read(buf)

        // Content-Lengthが明らかな場合
        if hasContentLen {
            // 読み込んだ分だけ残りのremainLenを減らす
            remainLen -= int64(n)

            // 残りのremainLenがないのにEOFを検出してない場合
            // (次の読み込みでEOFを検出するケース)
            if remainLen == 0 && err == nil {
                var scratch [1]byte
                var n1 int
                n1, err = body.Read(scratch[:]) // 追加で1byte読み込む
                remainLen -= int64(n1)
            }

            if remainLen < 0 {
                err = http2errReqBodyTooLong
                return err
            }
        }

        // EOFを検出した場合
        if err != nil {
            cc.mu.Lock()
            // cs.reqBodyClosed = リクエストボディがクローズされた際に通知されるチャネル
            // cs.reqBodyClosed != nil はボディへをクローズする処理がどこかで始まっていることを意味する
            // abortRequestBodyWrite() が実行されたり、RST_STREAMを受信するなど
            bodyClosed := cs.reqBodyClosed != nil
            cc.mu.Unlock()

            switch {
            case bodyClosed: // ボディがクローズされている場合
                return http2errStopReqBodyWrite // 送信を停止し、writeRequestの呼び出し元に返る
            case err == io.EOF: // EOFを検出した場合
                sawEOF = true // sawEOFをセット
                err = nil
            default:
                return err
            }
        }

        // リクエストボディの未送部分を取得
        remain := buf[:n]

        for len(remain) > 0 && err == nil {
            // 現在のウィンドウサイズに対して送信可能な長さをallowedを取得
            // ウィンドウが小さく送信できない場合はWINDOW_UPDATEの受信を待機
            var allowed int32
            allowed, err = cs.awaitFlowControl(len(remain))

            if err != nil {
                return err
            }

            cc.wmu.Lock()

            // 送信可能なサイズのリクエストボディを切り出す
            data := remain[:allowed]

            // これが最後に送信するDATAかどうかを判定
            remain = remain[allowed:]
            sentEnd = sawEOF && len(remain) == 0 && !hasTrailers

            // DATAフレームを書き出す
            // cs.ID = ストリームID
            // sentEndがtrueの場合はEND_STREAMフラグを立てる
            err = cc.fr.WriteData(cs.ID, sentEnd, data)
            if err == nil {
                err = cc.bw.Flush() // 送信後は即フラッシュ
            }

            cc.wmu.Unlock()
        }
        if err != nil {
            return err
        }
    }

    // すでにEND_STREAMを送信済みの場合
    if sentEnd {
        return nil // ここで即終了
    }

    // まだEND_STREAMを未送信の場合
    cc.mu.Lock()
    trailer := req.Trailer // トレーラを取得
    err = cs.abortErr
    cc.mu.Unlock()

    if err != nil {
        return err
    }

    cc.wmu.Lock()
    defer cc.wmu.Unlock()

    // トレーラがある場合
    var trls []byte
    if len(trailer) > 0 {
        // req.TrailerをHPACKエンコードしてHEADERS用のバイト列に変換
        trls, err = cc.encodeTrailers(trailer)
        if err != nil {
            return err
        }
    }

    if len(trls) > 0 { // トレーラを送信する必要がある場合
        // END_STREAMフラグを立ててHEADERSフレームを送信
        err = cc.writeHeaders(cs.ID, true, maxFrameSize, trls)
    } else { // トレーラを送信する必要がない場合
        // END_STREAMフラグを立ててHEADERSフレームを送信
        err = cc.fr.WriteData(cs.ID, true, nil)
    }

    if ferr := cc.bw.Flush(); ferr != nil && err == nil {
        err = ferr
    }

    return err
}

// hdrs = HPACKで圧縮済みのヘッダブロックの生バイト列を、HEADERS + CONTINUATION ...の列に分割して書き込む
func (cc *http2ClientConn) writeHeaders(streamID uint32, endStream bool, maxFrameSize int, hdrs []byte) error {
    // 最初のフレーム = HEADERSかどうかの判定
    first := true // first frame written (HEADERS is first, then CONTINUATION)

    for len(hdrs) > 0 && cc.werr == nil {
        // hdrsをmaxFrameSize ごとに切り出す
        chunk := hdrs
        if len(chunk) > maxFrameSize {
            chunk = chunk[:maxFrameSize]
        }
        hdrs = hdrs[len(chunk):]

        // 残りのヘッダがないかどうか
        endHeaders := len(hdrs) == 0

        if first {
            // HEADERSフレームの書き込み
            cc.fr.WriteHeaders(http2HeadersFrameParam{
                StreamID:      streamID,
                BlockFragment: chunk,
                EndStream:     endStream,
                EndHeaders:    endHeaders,
            })

            first = false
        } else {
            // CONTINUATIONフレームの書き込み
            cc.fr.WriteContinuation(streamID, endHeaders, chunk)
        }
    }

    cc.bw.Flush()
    return cc.werr
}
```
