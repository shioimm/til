## client/connection_factory.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client/connection_factory

```ruby
# frozen_string_literal: true
module Net
  class HTTP
    class Client
      class ConnectionFactory
        # H3 adds another connector here. It does not masquerade as a TCP socket.
        # Client::ConnectionFactory.open WIP
        def self.open(request, options, operation, proxy, http: nil)
          uri = request.uri

          http ||= Net::HTTP.new(
            uri.hostname,
            uri.port,
            proxy && proxy.hostname,
            proxy && proxy.port,
            proxy && proxy.user && URI::RFC2396_PARSER.unescape(proxy.user),
            proxy && proxy.password && URI::RFC2396_PARSER.unescape(proxy.password)
          )

          http.use_ssl = uri.scheme == 'https'
          options[:tls].each { |name, value| http.public_send("#{name}=", value) }
          http.max_retries = 0
          http.open_timeout = operation.remaining(options[:open_timeout])
          http.read_timeout = operation.remaining(options[:read_timeout])
          http.write_timeout = operation.remaining(options[:write_timeout])
          http.keep_alive_timeout = options[:idle_timeout]
          http.ignore_eof = false
          connect_deadline = Clock.now + options[:open_timeout]
          http.instance_variable_set(:@client_io_wrapper, proc { |io| TimedSocket.new(io, operation) }) if operation.deadline
          http.instance_variable_set(:@client_socket_observer, proc do |socket|
            http.open_timeout = operation.remaining([connect_deadline - Clock.now, 0].max)
            operation.on_cancel { socket.to_io.close unless socket.to_io.closed? }
          end)

          protocols = options[:protocols]

          if http.use_ssl? && OpenSSL::SSL::SSLContext.instance_methods.include?(:alpn_protocols=)
            alpn = protocols.map { |p| p == :http2 ? 'h2' : 'http/1.1' }
            http.instance_variable_set(:@client_alpn, alpn)
          elsif protocols == [:http2]
            raise ProtocolError, 'HTTP/2 requires HTTPS and ALPN support'
          end

          http.start
          operation.check!
          socket = http.instance_variable_get(:@socket).io
          socket = socket.raw_io if socket.is_a?(TimedSocket)
          selected = socket.respond_to?(:alpn_protocol) && socket.alpn_protocol

          if selected == 'h2'
            require_relative 'http2/session'
            http.instance_variable_set(:@socket, nil)
            http.instance_variable_set(:@started, false)
            HTTP2::Session.new(socket, operation)
          else
            if protocols == [:http2]
              raise ProtocolError, 'peer did not negotiate HTTP/2'
            end
            H1Session.new(http)
          end
        rescue Exception
          if http
            socket = http.instance_variable_get(:@socket)
            socket.close if socket && !socket.closed?
          end
          operation.check!
          raise
        end
      end

      class H1Session
        def initialize(http)
          @http = http
          @busy = false
          @closed = false
          @cancel_callback = proc { close }
          @connecting_socket = nil
          @get_template = nil
          @http.instance_variable_set(:@client_alpn, ['http/1.1']) if @http.use_ssl?
        end

        # Client::H1Session#reserve
        def reserve
          return nil if @closed || @busy
          @busy = true
        end

        def release(_reservation)
          @busy = false
        end

        def idle? = !@busy
        def closed? = @closed
        def discard_after_fork = close

        def close
          @closed = true
          @connecting_socket.close if @connecting_socket && !@connecting_socket.closed?
          buffered = @http.instance_variable_get(:@socket)
          buffered.io.close if buffered && !buffered.closed?
        rescue IOError, SystemCallError
          nil
        end

        def buffered_get(path, operation)
          complete = false
          operation.on_cancel(&@cancel_callback)
          @http.open_timeout = operation.options[:open_timeout]
          @http.read_timeout = operation.options[:read_timeout]
          @http.write_timeout = operation.options[:write_timeout]
          @http.instance_variable_set(:@client_socket_observer, proc do |socket|
            @connecting_socket = socket
            operation.check!
          end)
          # Only invariant default GET headers are cached. Every exchange owns
          # its request and writable header hash; auth and custom headers never
          # enter this template, including when another caller shares the session.
          unless @get_template
            @get_template = Net::HTTP::Get.new('/')
            @get_template.path.freeze
            @get_template.to_hash.each_value { |values| values.each(&:freeze); values.freeze }
            @get_template.instance_variable_get(:@header).freeze
            @get_template.freeze
          end
          request = @get_template.dup
          request.instance_variable_set(:@path, path)
          request.instance_variable_set(:@header, @get_template.to_hash)
          response = @http.request(request) do |r|
            r.instance_variable_set(:@client_capture_trailers, true)
            r.read_body
          end
          operation.check!
          complete = true
          response
        rescue IOError, EOFError, SystemCallError, Net::ReadTimeout, Net::WriteTimeout
          operation.check!
          raise
        ensure
          @http.instance_variable_set(:@client_socket_observer, nil)
          @connecting_socket = nil
          close unless complete
        end

        # The convenience adapter retains upstream request parsing, compression
        # and response-block behavior, with retries owned by the adapter.
        def exchange_legacy(request, operation, settings, &block)
          complete = false
          operation.on_cancel(&@cancel_callback)
          @http.open_timeout = operation.options[:open_timeout]
          @http.read_timeout = operation.options[:read_timeout]
          @http.write_timeout = operation.options[:write_timeout]
          @http.ignore_eof = settings[:ignore_eof]
          @http.response_body_encoding = settings[:response_body_encoding]
          @http.close_on_empty_response = settings[:close_on_empty_response]
          @http.max_retries = 0
          @http.instance_variable_set(:@client_socket_observer, proc do |socket|
            @connecting_socket = socket
            operation.check!
          end)
          response = @http.request(request, &block)
          operation.check!
          complete = true
          response
        ensure
          @http.instance_variable_set(:@client_socket_observer, nil)
          @connecting_socket = nil
          @http.ignore_eof = false
          @http.response_body_encoding = false
          @http.close_on_empty_response = false
          close unless complete
        end

        def exchange(request, operation, _reservation)
          operation.on_cancel { close }
          connect_deadline = Clock.now + operation.options[:open_timeout]
          @http.instance_variable_set(:@client_io_wrapper, operation.deadline && proc { |io| TimedSocket.new(io, operation) })
          @http.instance_variable_set(:@client_socket_observer, proc do |socket|
            @http.open_timeout = operation.remaining([connect_deadline - Clock.now, 0].max)
            operation.on_cancel { socket.to_io.close unless socket.to_io.closed? }
          end)
          @http.open_timeout = operation.remaining(operation.options[:open_timeout])
          @http.read_timeout = operation.options[:read_timeout]
          @http.write_timeout = operation.options[:write_timeout]
          buffered = @http.instance_variable_get(:@socket)
          raw_io = buffered.io.is_a?(TimedSocket) ? buffered.io.raw_io : buffered.io
          buffered.instance_variable_set(:@io, operation.deadline ? TimedSocket.new(raw_io, operation) : raw_io)
          body_permitted = request.body_length != 0 || %w[POST PUT PATCH].include?(request.method)
          req = Net::HTTPGenericRequest.new(request.method, body_permitted, request.method != 'HEAD', request.uri, {})
          req.delete('accept-encoding')
          request.headers.each { |name, values| req[name] = values }
          # Compression and retries belong to the protocol-neutral request layer.
          req.instance_variable_set(:@decode_content, false)
          if request.body_length != 0
            body_reader = BodyReader.new(request.body)
            req.body_stream = body_reader
            if request.body_length
              req.content_length = request.body_length
            else
              req['transfer-encoding'] = 'chunked'
            end
          elsif body_permitted
            req.body = ''
          end
          complete = false
          exposed = nil
          @http.request(req) do |raw|
            raw.decode_content = false
            raw.instance_variable_set(:@client_capture_trailers, true)
            raw_read = raw.method(:read_body)
            exposed = raw.dup
            exposed.instance_variable_set(:@header, raw.to_hash.transform_values(&:dup))
            exposed.extend(ResponseMethods)
            exposed.instance_variable_set(:@client_body_consumed, false)
            exposed.instance_variable_set(:@client_body_complete, false)
            exposed.instance_variable_set(:@client_body_allowed, raw.instance_variable_get(:@body_exist))
            reader = ResponseBody.new(exposed, operation) do |&sink|
              raw_read.call(&sink)
              exposed.instance_variable_set(:@client_trailers, raw.trailers)
            end
            exposed.instance_variable_set(:@client_body_source, proc { |&sink| reader.each(&sink) })
            begin
              yield exposed
              if !exposed.instance_variable_get(:@client_body_complete)
                close
                raw.instance_variable_set(:@read, true)
              end
            ensure
              exposed.instance_variable_set(:@client_body_source, nil)
              exposed.instance_variable_set(:@socket, nil)
            end
          end
          complete = true
          exposed
        ensure
          body_reader.close if body_reader
          @http.instance_variable_set(:@client_socket_observer, nil)
          @http.instance_variable_set(:@client_io_wrapper, nil)
          buffered = @http.instance_variable_get(:@socket)
          if buffered && buffered.io.is_a?(TimedSocket)
            buffered.instance_variable_set(:@io, buffered.io.raw_io)
          end
          close unless complete
        end
      end
      private_constant :ConnectionFactory, :H1Session
    end
  end
end
```
