## connection.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/connection.rb

```ruby
# frozen_string_literal: true

module Net
  class HTTP
    # Internal TCP/TLS connection establishment, shared by legacy HTTP and Client.
    module Connection
      # Connection#connect
      def connect
        if use_ssl?
          # reference early to load OpenSSL before connecting,
          # as OpenSSL may take time to load.
          @ssl_context = OpenSSL::SSL::SSLContext.new # TLS接続設定
        end

        # conn_addr = TCP接続先アドレス
        # conn_port = TCP接続先ポート番号
        if proxy?
          conn_addr = proxy_address
          conn_port = proxy_port
        else
          conn_addr = conn_address
          conn_port = port
        end

        debug "opening connection to #{conn_addr}:#{conn_port}..."

        begin
          s = timeouted_connect(conn_addr, conn_port) # => Net::HTTP#timeouted_connect (lib/net/http.rb)

          # Net::HTTP#timeouted_connect (lib/net/http.rb)
          #
          #   def timeouted_connect(conn_addr, conn_port)
          #     if TCP_SOCKET_NEW_HAS_OPEN_TIMEOUT
          #       TCPSocket.open(conn_addr, conn_port, @local_host, @local_port, open_timeout: @open_timeout)
          #     else
          #       Timeout.timeout(@open_timeout, Net::OpenTimeout) {
          #         TCPSocket.open(conn_addr, conn_port, @local_host, @local_port)
          #       }
          #     end
          #   end

        rescue => e
          if (defined?(IO::TimeoutError) &&
              e.is_a?(IO::TimeoutError)) ||
              e.is_a?(Errno::ETIMEDOUT)  # for compatibility with previous versions

            e = Net::OpenTimeout.new(e)
          end

          raise e, "Failed to open TCP connection to " + "#{conn_addr}:#{conn_port} (#{e.message})"
        end

        # フックが設定されていればTCPSocketを渡して呼び出す
        @client_socket_observer.call(s) if @client_socket_observer
        s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        debug "opened"

        if use_ssl?
          if proxy?
            if @proxy_use_ssl
              proxy_sock = OpenSSL::SSL::SSLSocket.new(s)
              ssl_socket_connect(proxy_sock, @open_timeout)
            else
              proxy_sock = s
            end

            proxy_sock = @client_io_wrapper.call(proxy_sock) if @client_io_wrapper

            proxy_sock = BufferedIO.new(
              proxy_sock,
              read_timeout: @read_timeout,
              write_timeout: @write_timeout,
              continue_timeout: @continue_timeout,
              debug_output: @debug_output
            )

            buf = +"CONNECT #{conn_address}:#{@port} HTTP/#{HTTPVersion}\r\n" "Host: #{@address}:#{@port}\r\n"

            if proxy_user
              credential = ["#{proxy_user}:#{proxy_pass}"].pack('m0')
              buf << "Proxy-Authorization: Basic #{credential}\r\n"
            end

            buf << "\r\n"
            proxy_sock.write(buf)
            HTTPResponse.read_new(proxy_sock).value
            # assuming nothing left in buffers after successful CONNECT response
          end

          ssl_parameters = {}
          iv_list = instance_variables # 現在のNet::HTTPオブジェクトに存在するインスタンス変数名

          # 現在のNet::HTTPオブジェクトが保持している値を利用してTLS設定用のインスタンス変数名をセットする
          SSL_IVNAMES.each_with_index do |ivname, i|
            if iv_list.include?(ivname)
              value = instance_variable_get(ivname)

              unless value.nil?
                ssl_parameters[SSL_ATTRIBUTES[i]] = value
              end
            end
          end

          # Net::HTTP::SSL_ATTRIBUTES (lib/net/http.rb)
          #   SSL_ATTRIBUTES = [
          #     :ca_file,
          #     :ca_path,
          #     :cert,
          #     :cert_store,
          #     :ciphers,
          #     :extra_chain_cert,
          #     :key,
          #     :ssl_timeout,
          #     :ssl_version,
          #     :min_version,
          #     :max_version,
          #     :verify_callback,
          #     :verify_depth,
          #     :verify_mode,
          #     :verify_hostname,
          #   ].freeze
          #
          # Net::HTTP::SSL_IVNAMES  (lib/net/http.rb)
          #   SSL_IVNAMES = SSL_ATTRIBUTES.map { |a| "@#{a}".to_sym }.freeze

          # SSLContextにTLS設定をセット
          @ssl_context.set_params(ssl_parameters)
          # Client::ConnectionFactory.openで用意したALPNをセット
          @ssl_context.alpn_protocols = @client_alpn if @client_alpn

          # Client::ConnectionFactory.open
          #   protocols = options[:protocols] # Client::DEFAULTSではprotocols: [:http2, :http1]
          #   alpn = protocols.map { |p| p == :http2 ? 'h2' : 'http/1.1' }
          #   http.instance_variable_set(:@client_alpn, alpn)

          if !@ssl_context.session_cache_mode.nil? # a dummy method on JRuby
            @ssl_context.session_cache_mode =
              OpenSSL::SSL::SSLContext::SESSION_CACHE_CLIENT | # クライアント側のTLSセッションキャッシュ機構を有効化
              OpenSSL::SSL::SSLContext::SESSION_CACHE_NO_INTERNAL_STORE # OpenSSL内部のキャッシュには自動保存しない
          end

          if @ssl_context.respond_to?(:session_new_cb) # not implemented under JRuby
            # 新しいTLSセッションが作られたとき、@ssl_sessionに作成されたTLSセッションを保存する
            @ssl_context.session_new_cb = proc {|sock, sess| @ssl_session = sess }
          end

          # Still do the post_connection_check below even if connecting to IP address
          verify_hostname = @ssl_context.verify_hostname # 証明書のホスト名を検証するかどうか

          # Server Name Indication (SNI) RFC 3546/6066
          case @address
          when Resolv::IPv4::Regex, Resolv::IPv6::Regex # 接続先がIPv4 / IPv6のアドレスリテラルの場合
            # don't set SNI, as IP addresses in SNI is not valid
            # per RFC 6066, section 3.

            # Avoid openssl warning
            @ssl_context.verify_hostname = false
          else
            ssl_host_address = @address
          end

          debug "starting SSL for #{conn_addr}:#{conn_port}..."

          # TCPSocketをSSLSocketでラップ
          s = OpenSSL::SSL::SSLSocket.new(s, @ssl_context)
          s.sync_close = true
          @client_socket_observer.call(s) if @client_socket_observer
          s.hostname = ssl_host_address if s.respond_to?(:hostname=) && ssl_host_address

          # 以前保存したTLSセッションがあり、まだ有効期限内の場合
          if @ssl_session and
             Process.clock_gettime(Process::CLOCK_REALTIME) < (@ssl_session.time.to_f + @ssl_session.timeout)
            s.session = @ssl_session # 保存済みのTLSセッションをソケットに設定
          end

          # TLSハンドシェイクを実行
          ssl_socket_connect(s, @open_timeout)

          # 証明書検証が無効化されていない & verify_hostnameが有効
          if (@ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE) && verify_hostname
            # 相手の証明書が、接続したいホスト名またはIPアドレスに対応しているかを確認
            s.post_connection_check(@address)
          end

          debug "SSL established, protocol: #{s.ssl_version}, cipher: #{s.cipher[0]}"
        end

        # s = HTTPならTCPSocket、HTTPSならSSLSocket
        # フックが設定されていればsを渡して呼び出す
        buffered_socket = @client_io_wrapper ? @client_io_wrapper.call(s) : s

        # buffered_socketをNet::HTTPが送受信に使用するBufferedIOでラップ
        @socket = BufferedIO.new(
          buffered_socket,
          read_timeout: @read_timeout,
          write_timeout: @write_timeout,
          continue_timeout: @continue_timeout,
          debug_output: @debug_output
        )
        @last_communicated = nil # 最後に通信した時刻をnilに設定

        on_connect # => Net::HTTP#on_connect (lib/net/http.rb)

        # Net::HTTP#on_connect (lib/net/http.rb)
        #
        #   def on_connect # 接続にフックして何かを実行したい場合にサブクラスでオーバーライドされることがある
        #   end
        #   private :on_connect

      rescue => exception
        if s
          debug "Conn close because of connect error #{exception}"
          s.close
        end

        raise
      end

      private :connect
    end

    private_constant :Connection
  end
end
```
