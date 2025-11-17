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

  # Net::BufferedIO#read (lib/net/protocol.rb)

  def read(len, dest = ''.b, ignore_eof = false)
    LOG "reading #{len} bytes..."
    read_bytes = 0

    begin
      while read_bytes + rbuf_size < len # => Net::BufferedIO#rbuf_size

        if s = rbuf_consume_all # => Net::BufferedIO#rbuf_consume_all
          read_bytes += s.bytesize
          dest << s
        end

        rbuf_fill # 実際にバッファから読み込む => Net::BufferedIO#rbuf_fill
      end

      s = rbuf_consume(len - read_bytes) # => Net::BufferedIO#rbuf_consume
      read_bytes += s.bytesize
      dest << s
    rescue EOFError
      raise unless ignore_eof
    end

    LOG "read #{read_bytes} bytes"
    dest
  end

  # Net::BufferedIO#read_all (lib/net/protocol.rb)

  def read_all(dest = ''.b)
    LOG 'reading all...'
    read_bytes = 0

    begin
      while true
        if s = rbuf_consume_all # => Net::BufferedIO#rbuf_consume_all
          read_bytes += s.bytesize
          dest << s
        end

        rbuf_fill # 実際にバッファから読み込む => Net::BufferedIO#rbuf_fill
      end
    rescue EOFError
      ;
    end
    LOG "read #{read_bytes} bytes"
    dest
  end

  # Net::BufferedIO#rbuf_size (lib/net/protocol.rb)

  def rbuf_size
    @rbuf.bytesize - @rbuf_offset
  end

  # Net::BufferedIO#rbuf_consume_all (lib/net/protocol.rb)

  def rbuf_consume_all
    rbuf_consume if rbuf_size > 0 # => Net::BufferedIO#rbuf_consume
  end

  # Net::BufferedIO#rbuf_consume (lib/net/protocol.rb)

  # @rbufを消費するイメージ
  def rbuf_consume(len = nil)
    if @rbuf_offset == 0 && (len.nil? || len == @rbuf.bytesize)
      s = @rbuf
      @rbuf = ''.b
      @rbuf_offset = 0
      @rbuf_empty = true
    elsif len.nil?
      s = @rbuf.byteslice(@rbuf_offset..-1)
      @rbuf = ''.b
      @rbuf_offset = 0
      @rbuf_empty = true
    else
      s = @rbuf.byteslice(@rbuf_offset, len)
      @rbuf_offset += len
      @rbuf_empty = @rbuf_offset == @rbuf.bytesize
      rbuf_flush # => Net::BufferedIO#rbuf_flush

      # Net::BufferedIO#rbuf_flush (lib/net/protocol.rb)
      #
      #   def rbuf_flush
      #     if @rbuf_empty
      #       @rbuf.clear
      #       @rbuf_offset = 0
      #     end
      #     nil
      #   end
    end

    @debug_output << %Q[-> #{s.dump}\n] if @debug_output
    s
  end

  # Net::BufferedIO#rbuf_fill (lib/net/protocol.rb)

  # 実際に読み込む
  def rbuf_fill
    tmp = @rbuf_empty ? @rbuf : nil

    case rv = @io.read_nonblock(BUFSIZE, tmp, exception: false)
    when String
      @rbuf_empty = false

      if rv.equal?(tmp)
        @rbuf_offset = 0
      else
        @rbuf << rv
        rv.clear
      end
      return
    when :wait_readable
      (io = @io.to_io).wait_readable(@read_timeout) or raise Net::ReadTimeout.new(io)
      # continue looping
    when :wait_writable
      # OpenSSL::Buffering#read_nonblock may fail with IO::WaitWritable.
      # http://www.openssl.org/support/faq.html#PROG10
      (io = @io.to_io).wait_writable(@read_timeout) or raise Net::ReadTimeout.new(io)
      # continue looping
    when nil
      raise EOFError, 'end of file reached'
    end while true
  end

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
