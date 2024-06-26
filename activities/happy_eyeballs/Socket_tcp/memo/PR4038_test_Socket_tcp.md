# PR#4038のテスト
https://github.com/ruby/ruby/blob/0820228d29fa8de223f21043fb51988d32bfa97c/test/socket/test_socket.rb

```ruby
# ruby/test/socket/test_socket.rb

class TestSocket < Test::Unit::TestCase
  # ...
  # IPv4アドレスの名前解決に時間がかかる場合
  def test_getaddrinfo_v4_slow
    assert_separately(%w[-W1], <<-'EOS')
      require "socket"

      # IPv6アドレスにバインドされたテスト用のサーバプロセスを作成
      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      port = server.addr[1]

      # Addrinfo::getaddrinfo をオーバーライドし、DNS問い合わせ開始から10秒後にIPv4アドレスを返すようにする
      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, _|
        if family == :PF_INET
          sleep(10)
          [Addrinfo.tcp("127.0.0.1", port)]
        else
          [Addrinfo.tcp("::1", port)]
        end
      end

      # サーバの accept をスレッド内で実行
      serv_thread = Thread.new { server.accept }

      # Socket.tcp を実行し、IPv6アドレスにバインドされたサーバに接続したクライアントソケットを返す
      Socket.tcp("localhost", port)
      serv_thread.join
    EOS
  end

  # IPv6アドレスの名前解決に時間がかかる場合
  def test_getaddrinfo_v6_slow
    assert_separately(%w[-W1], <<-'EOS')
      require "socket"

      # IPv6アドレスにバインドされたテスト用のサーバプロセスを作成
      server = TCPServer.new("127.0.0.1", 0)

      port = server.addr[1]

      # Addrinfo::getaddrinfo をオーバーライドし、DNS問い合わせ開始から10秒後にIPv6アドレスを返すようにする
      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, _|
        if family == :PF_INET6
          sleep(10)
          [Addrinfo.tcp("::1", port)]
        else
          [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      # サーバの accept をスレッド内で実行
      serv_thread = Thread.new { server.accept }

      # Socket.tcp を実行し、IPv4アドレスにバインドされたサーバに接続したクライアントソケットを返す
      Socket.tcp("localhost", port)
      serv_thread.join
    EOS
  end

  # Resolution Delay 中にIPv6アドレスを名前解決できた場合
  def test_getaddrinfo_v6_finished_in_resolution_delay
    assert_separately(%w[-W1], <<-'EOS')
      require "socket"

      # IPv6アドレスにバインドされたテスト用のサーバプロセスを作成
      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      port = server.addr[1]

      # Addrinfo::getaddrinfo をオーバーライドし、Resolution Delay 時間内にIPv6アドレスを返すようにする
      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, _|
        if family == :PF_INET6
          sleep(0.025) #  Socket::RESOLUTION_DELAY (private) is 0.05
          [Addrinfo.tcp("::1", port)]
        else
          [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      # サーバの accept をスレッド内で実行
      serv_thread = Thread.new { server.accept }

      # Socket.tcp を実行し、IPv6アドレスにバインドされたサーバに接続したクライアントソケットを返す
      Socket.tcp("localhost", port)
      serv_thread.join
    EOS
  end

  # 名前解決がタイムアウトする場合
  def test_resolv_timeout
    assert_separately(%w[-W1], <<-'EOS')
      require "socket"

      # これ要る?
      original = Addrinfo.singleton_method(:getaddrinfo)

      # Addrinfo::getaddrinfo をオーバーライドし、永久に何も返さないようにする
      Addrinfo.define_singleton_method(:getaddrinfo) {|*arg| sleep }

      sock = nil

      # Errno::ETIMEDOUT を送出
      assert_raise(Errno::ETIMEDOUT) do
        sock = Socket.tcp("localhost", 9, resolv_timeout: 0.1)
      end
    EOS
  end

  # 名前解決時に何らかの例外が発生する場合
  def test_unhandled_exception_in_getaddrinfo_th
    assert_separately(%w[-W1], <<-'EOS')
      require "socket"

      # Addrinfo::getaddrinfo をオーバーライドし、例外を送出するようにする
      Addrinfo.define_singleton_method(:getaddrinfo) {|*arg| raise }

      sock = nil

      # Errno::ETIMEDOUT を送出
      assert_raise(Errno::ETIMEDOUT) do
        sock = Socket.tcp("localhost", 9, resolv_timeout: 0.1)
      end
    EOS
  end

  # 名前解決時に SocketError 例外が発生する場合
  def test_unhandled_socketerror_in_getaddrinfo_th
    assert_separately(%w[-W1], <<-'EOS')
      require "socket"

      # Addrinfo::getaddrinfo をオーバーライドし、SocketError 例外を送出するようにする
      Addrinfo.define_singleton_method(:getaddrinfo) {|*arg| raise SocketError }

      sock = nil

      # Errno::ETIMEDOUT を送出
      assert_raise(Errno::ETIMEDOUT) do
        sock = Socket.tcp("localhost", 9, resolv_timeout: 0.1)
      end
    EOS
  end
  # ...
end if defined?(Socket)
```
