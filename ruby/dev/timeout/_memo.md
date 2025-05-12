## 多言語の事情

#### PHP

```php
// https://www.php.net/manual/en/function.stream-socket-client.php
stream_socket_client(
    string $address,
    int &$error_code = null,
    string &$error_message = null,
    ?float $timeout = null,
    int $flags = STREAM_CLIENT_CONNECT,
    ?resource $context = null
): resource|false

// timeout = connect(2)がタイムアウトするまで (非同期で接続を試みていない場合にのみ適用)
```

https://github.com/php/php-src/blob/bda0939bd2e52fcac94a299110716b6804d7f31b/ext/standard/streamsfuncs.c#L96

#### Python
```python
# https://docs.python.org/3/library/socket.html#socket.create_connection
socket.create_connection(
  address,
  timeout=GLOBAL_DEFAULT,
  source_address=None,
  *,
  all_errors=False
)

# timeout = 接続を試みる前にそのソケットインスタンスに対してタイムアウトが設定される
```

https://github.com/python/cpython/blob/2b761d1122b3b003457c5eff5db851691041bc6d/Lib/socket.py#L828

#### Go

```go
// https://pkg.go.dev/net#DialTimeout
func DialTimeout(network, address string, timeout time.Duration) (Conn, error)

// timeout = 名前解決にかかる時間も含まれる
// 複数のIPアドレスに解決される場合、タイムアウトは各接続試行に分配され、適切な時間が割り当てられる (???)
```

https://github.com/golang/go/blob/e282cbb11256db717b95f9d8cf8c050cd4c4f7c2/src/net/dial.go#L484

#### Rust

```rust
// https://doc.rust-lang.org/std/net/struct.TcpStream.html#method.connect_timeout
pub fn connect_timeout(
    addr: &SocketAddr,
    timeout: Duration,
) -> Result<TcpStream>

// ひとつのSocketAddrを取る。個々のアドレスごとにタイムアウトを適用する
// ノンブロッキングモードでconnectを呼び出し、接続処理の完了を待つためにOS固有の仕組みを利用する
```

https://doc.rust-lang.org/src/std/net/tcp.rs.html#178-180
