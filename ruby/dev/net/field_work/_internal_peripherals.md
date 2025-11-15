# net-http 周辺現地調査 (202511時点)

## `Net::Protocol#ssl_socket_connect`

```ruby
# (lib/net/protocol.rb)

class Protocol
  # HTTP#connectから呼び出されている
  #   - プロキシを介してTLSで接続する際
  #   - オリジンに直接TLSで接続する際
  def ssl_socket_connect(s, timeout) # 引数s = OpenSSL::SSL::SSLSocket(#<TCPSocket>)
    if timeout

      while true
        raise Net::OpenTimeout if timeout <= 0
        start = Process.clock_gettime Process::CLOCK_MONOTONIC

        # to_io is required because SSLSocket doesn't have wait_readable yet
        case s.connect_nonblock(exception: false) # => OpenSSL::SSL::SSLSocket#connect_nonblock
        when :wait_readable; s.to_io.wait_readable(timeout)
        when :wait_writable; s.to_io.wait_writable(timeout)
        else; break
        end

        timeout -= Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
      end
    else
      s.connect # => OpenSSL::SSL::SSLSocket#connect
    end
  end
end
```

## `Net::BufferedIO`

```ruby
# (lib/net/protocol.rb)

class BufferedIO
  def initialize(io, read_timeout: 60, write_timeout: 60, continue_timeout: nil, debug_output: nil)
    @io = io
    @read_timeout = read_timeout
    @write_timeout = write_timeout
    @continue_timeout = continue_timeout
    @debug_output = debug_output
    @rbuf = ''.b
    @rbuf_empty = true
    @rbuf_offset = 0
  end

  attr_reader :io
  attr_accessor :read_timeout
  attr_accessor :write_timeout
  attr_accessor :continue_timeout
  attr_accessor :debug_output

  # ...
end
```

## `Net::ReadAdapter`

```ruby
# (lib/net/protocol.rb)

class ReadAdapter
  def initialize(block)
    @block = block
  end

  # ...
end
```
