## client/http2/session.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client/http2/session.rb

```ruby
# frozen_string_literal: true
require_relative 'hpack'

module Net
  class HTTP
    class Client
      module HTTP2
        class Session
          PREFACE = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n".b.freeze

          # Client::HTTP2::Stream
          Stream = Struct.new(
            :id,
            :headers,
            :queue,
            :remote_end,
            :sent,
            :cancelled,
            :error,
            :send_window,
            :receive_window,
            :received,
            :trailers,
            :method,
            :informationals,
            :reset_queued,
            :upload_stopped
          )

          def initialize(socket, operation)
            @socket = socket
            @closed = false
            @draining = false

            @mutex = Mutex.new
            @reader = Mutex.new
            @writer = Mutex.new

            @streams = {}
            @reservations = {}
            @next_id = 1
            @peer_limit = 100

            @initial_window = 65_535
            @send_window = 65_535
            @receive_window = 1_048_576

            @encoder = HPACK.new
            @decoder = HPACK.new

            @max_frame = 16_384
            @input = ''.b
            @continuation = nil
            @pending_control = []
            @settings_received = false

            operation.on_cancel { close }

            write_bytes(PREFACE, operation)
            write_frame(4, 0, 0, [2, 0, 6, 65_536].pack('nNnN'), operation)
            write_frame(8, 0, 0, [@receive_window - 65_535].pack('N'), operation)

            deadline = Clock.now + operation.options[:open_timeout]

            until @settings_received
              raise Net::OpenTimeout, 'HTTP/2 SETTINGS timeout' if Clock.now >= deadline
              pump(operation, deadline)
            end
          rescue Exception
            close
            raise
          end

          def reserve
            @mutex.synchronize do
              if @closed || @draining || !@settings_received || @reservations.size >= @peer_limit
                return nil
              end

              pending = @reservations.size - @streams.size

              if @next_id + 2 * pending > 0x7fffffff
                @draining = true
                return nil
              end

              stream = Stream.new(
                id: nil,
                headers: nil,
                queue: [],
                remote_end: false,
                sent: false,
                cancelled: false,
                error: nil,
                send_window: @initial_window,
                receive_window: 65_535,
                received: 0,
                trailers: {},
                method: nil,
                informationals: 0
              )

              @reservations[stream.object_id] = stream
              stream
            end
          end

          def release(stream)
            @mutex.synchronize do
              @streams.delete(stream.id)
              @reservations.delete(stream.object_id)
            end
          end

          def idle?
            @mutex.synchronize { @reservations.empty? }
          end

          def closed?
            @closed || (@draining && idle?)
          end

          def discard_after_fork
            @socket.to_io.close unless @socket.to_io.closed?
            @closed = true
          rescue IOError, SystemCallError
            nil
          end

          def close
            @closed = true
            @socket.to_io.close unless @socket.to_io.closed?
          rescue IOError, SystemCallError
            nil
          end

          def progress(operation)
            pump(operation)
          end

          def exchange(request, operation, stream)
            operation.on_cancel { cancel(stream) }
            complete = false

            begin
              stream.method = request.method
              send_request(request, stream, operation)
              deadline = Clock.now + operation.options[:read_timeout]

              loop do
                headers = @mutex.synchronize { check_stream(stream); stream.headers }
                break if headers
                read_until(operation, deadline)
              end

              headers = stream.headers
              code = headers.assoc(':status')[1]

              klass =
                Net::HTTPResponse::CODE_TO_OBJ[code] ||
                Net::HTTPResponse::CODE_CLASS_TO_OBJ[code[0,1]] ||
                Net::HTTPUnknownResponse

              response = klass.new('2.0', code, nil)

              headers.each { |name,value| response.add_field(name, value) unless name.start_with?(':') }

              response.extend(ResponseMethods)
              response.instance_variable_set(:@uri, request.uri)
              response.instance_variable_set(:@client_body_consumed, false)
              response.instance_variable_set(:@client_body_complete, false)
              response.instance_variable_set(
                :@client_body_allowed,
                request.method != 'HEAD' && klass.body_permitted?
              )

              expected_length = response.content_length

              source = proc { |&sink|
                loop do
                  deadline = Clock.now + operation.options[:read_timeout]
                  chunk = nil

                  loop do
                    ended = @mutex.synchronize {
                      check_stream(stream)
                      chunk = stream.queue.shift
                      stream.remote_end
                    }

                    break if chunk || ended

                    read_until(operation, deadline)
                  end

                  break unless chunk

                  sink.call(chunk)
                  @mutex.synchronize { stream.receive_window += chunk.bytesize }

                  unless chunk.empty? || stream.remote_end
                    write_frame(8, 0, stream.id, [chunk.bytesize].pack('N'), operation)
                  end
                end

                validate_length(response, stream, expected_length)

                response.instance_variable_set(
                  :@client_trailers,
                  stream.trailers.transform_values { |values| values.freeze }.freeze
                )
              }

              reader = ResponseBody.new(response, operation, &source)
              response.instance_variable_set(:@client_body_source, proc { |&sink| reader.each(&sink) })

              begin
                yield response
              ensure
                response.instance_variable_set(:@client_body_source, nil)
              end

              complete = stream.remote_end && stream.queue.empty?
              response
            ensure
              unless complete
                cancel(stream)

                unless @closed
                  cleanup = Operation.new(operation.options.merge(timeout: 0.1))

                  begin
                    flush_control(cleanup)
                  rescue IOError, SystemCallError, Timeout::Error
                    # The request's original error remains authoritative.
                  end
                end
              end
            end
          end

          private

          def check_stream(stream)
            raise stream.error if stream.error
            raise CancelledError, 'stream cancelled' if stream.cancelled
            raise EOFError, 'HTTP/2 connection closed' if @closed
          end

          def cancel(stream)
            send_reset = @mutex.synchronize do
              was_open = stream.sent && !stream.remote_end && !stream.reset_queued
              stream.reset_queued = true if was_open
              stream.cancelled = true
              stream.queue.clear
              was_open
            end
            # Cancellation may originate in another thread. Closing one stream must
            # never close a shared socket. Defer RST to the next elected caller.
            @mutex.synchronize { (@pending_control ||= []) << [3, 0, stream.id, [8].pack('N')] } if send_reset
          end

          def send_request(request, stream, operation)
            headers = [
              [':method', request.method],
              [':scheme', request.uri.scheme],
              [
                ':authority',
                 request.headers.fetch('host') {
                   [request.uri.host + (request.uri.port == 443 ? '' : ":#{request.uri.port}")]
                 }.first
              ],
              [':path', request.request_target]
            ]

            request.headers.each do |name, values|
              next if name == 'host'

              if %w[connection keep-alive proxy-connection transfer-encoding upgrade].include?(name)
                raise ArgumentError, "#{name} is not allowed in HTTP/2"
              end

              if name == 'te' && values != ['trailers']
                raise ArgumentError, 'HTTP/2 TE must be trailers'
              end

              values.each do |value|
                headers << [name, value]
              end
            end

            if request.body_length && !request.headers.key?('content-length') && request.body_length > 0
              headers << ['content-length', request.body_length.to_s]
            end

            acquire_writer(operation) do
              # Reservations consume capacity, but stream IDs follow the order
              # in which opening HEADERS are emitted on this connection.
              @mutex.synchronize do
                check_stream(stream)
                stream.id = @next_id
                @next_id += 2
                @streams[stream.id] = stream
              end

              block = @encoder.encode(headers)
              offset = 0

              begin
                part = block.byteslice(offset, @max_frame)
                offset += part.bytesize

                flags = offset == block.bytesize ? 4 : 0
                flags |= 1 if offset == part.bytesize && request.body_length == 0

                write_frame_unlocked(offset == part.bytesize ? 1 : 9, flags, stream.id, part, operation)
              end while offset < block.bytesize

              stream.sent = true
            end

            return if request.body_length == 0

            sent = 0

            request.each_body_chunk do |chunk|
              offset = 0

              while offset < chunk.bytesize
                operation.check!
                deadline = Clock.now + operation.options[:write_timeout]
                size = nil

                loop do
                  size = @mutex.synchronize {
                    check_stream(stream)
                    return if stream.upload_stopped

                    amount = [chunk.bytesize - offset, @max_frame, @send_window, stream.send_window].min

                    if amount > 0
                      @send_window -= amount
                      stream.send_window -= amount
                      amount
                    end
                  }

                  break if size
                  raise Net::WriteTimeout, 'HTTP/2 flow-control timeout' if Clock.now >= deadline

                  pump(operation, deadline)
                end

                begin
                  acquire_writer(operation) do
                    @mutex.synchronize do
                      check_stream(stream)

                      if stream.upload_stopped
                        @send_window += size
                        return
                      end
                    end

                    write_frame_unlocked(0, 0, stream.id, chunk.byteslice(offset, size), operation)
                  end
                rescue Exception
                  # Cancellation while waiting for the writer has not consumed
                  # peer credit. A partial write instead closes the connection.
                  unless @closed
                    @mutex.synchronize do
                      @send_window += size
                    end
                  end

                  raise
                end

                offset += size
                sent += size
              end
            end

            if request.body_length && sent != request.body_length
              raise IOError, 'request body length changed during upload'
            end

            acquire_writer(operation) do
              @mutex.synchronize do
                check_stream(stream)
                return if stream.upload_stopped
              end

              write_frame_unlocked(0, 1, stream.id, ''.b, operation)
            end
          end

          def read_until(operation, deadline)
            operation.check!
            raise Net::ReadTimeout, 'HTTP/2 stream read timeout' if Clock.now >= deadline
            pump(operation, deadline)
          end

          def pump(operation, deadline = nil)
            operation.check!

            unless @reader.try_lock
              Wait.pause(operation)
              return
            end

            begin
              flush_control(operation)
              parse_available(operation)

              wait = operation.remaining(0.02)
              wait = [wait, [deadline - Clock.now, 0].max].min if deadline

              data = @socket.read_nonblock(16_384, exception: false)

              if data == :wait_readable || data == :wait_writable
                io = @socket.to_io
                data == :wait_readable ? io.wait_readable(wait) : io.wait_writable(wait)
                return
              end

              raise EOFError, 'HTTP/2 peer closed connection' unless data

              @input << data
              parse_available(operation)
            rescue ProtocolError, EOFError, IOError, SystemCallError, OpenSSL::SSL::SSLError => error
              close
              @mutex.synchronize { @reservations.each_value { |stream| stream.error ||= error } }
              raise
            ensure
              @reader.unlock
            end
          end

          def parse_available(operation)
            while @input.bytesize >= 9
              length = (@input.getbyte(0) << 16) | (@input.getbyte(1) << 8) | @input.getbyte(2)

              raise ProtocolError, 'HTTP/2 frame exceeds advertised size' if length > 16_384
              return if @input.bytesize < 9 + length

              type = @input.getbyte(3)
              flags = @input.getbyte(4)
              id = @input.byteslice(5,4).unpack1('N') & 0x7fffffff
              payload = @input.byteslice(9, length)

              @input = @input.byteslice(9 + length, @input.bytesize) || ''.b

              controls = @mutex.synchronize { handle_frame(type, flags, id, payload) }

              @mutex.synchronize do
                @pending_control.concat(controls)
              end

              flush_control(operation)
            end
          end

          def flush_control(operation)
            loop do
              frame = @mutex.synchronize { @pending_control.shift }
              break unless frame

              begin
                write_frame(*frame, operation)
              rescue Exception
                # A caller can be cancelled after parsing another stream's
                # frames. Preserve unsent connection updates for the next caller.
                @mutex.synchronize { @pending_control.unshift(frame) } unless @closed
                raise
              end
            end
          end

          def handle_frame(type, flags, id, payload)
            if !@settings_received && (type != 4 || flags & 1 != 0)
              raise ProtocolError, 'first peer frame must be SETTINGS'
            end

            if @continuation && (type != 9 || id != @continuation[0])
              raise ProtocolError, 'interleaved header continuation'
            end

            output = []
            stream = @streams[id]

            case type
            when 0 # DATA
              raise ProtocolError, 'DATA on invalid stream' if id.zero? || id.even? || id >= @next_id

              @receive_window -= payload.bytesize
              raise ProtocolError, 'connection flow control exceeded' if @receive_window < 0

              data = unpad(payload, flags)

              if stream && !stream.cancelled
                if !stream.headers || stream.remote_end
                  raise ProtocolError, 'DATA before headers or after end'
                end

                stream.receive_window -= payload.bytesize

                if stream.receive_window < 0
                  raise ProtocolError, 'stream flow control exceeded'
                end

                code = stream.headers.assoc(':status')[1]
                if !data.empty? && (stream.method == 'HEAD' || %w[204 304].include?(code))
                  raise ProtocolError, 'body forbidden for response'
                end

                stream.received += data.bytesize
                stream.queue << data unless data.empty?
                padding = payload.bytesize - data.bytesize

                if padding > 0
                  stream.receive_window += padding
                  output << [8, 0, id, [padding].pack('N')]
                end

                stream.remote_end = true if flags & 1 != 0
              end

              if payload.bytesize > 0
                @receive_window += payload.bytesize
                output << [8, 0, 0, [payload.bytesize].pack('N')]
              end

            when 1 # HEADERS
              raise ProtocolError, 'HEADERS on invalid stream' if id.zero? || id.even? || id >= @next_id

              data = unpad(payload, flags)

              if flags & 0x20 != 0
                raise ProtocolError, 'truncated priority' if data.bytesize < 5
                dependency = data.unpack1('N') & 0x7fffffff
                raise ProtocolError, 'self-dependent stream' if dependency == id
                data = data.byteslice(5, data.bytesize) || ''.b
              end

              @continuation = [id, data, flags & 1 != 0]
              finish_headers(stream) if flags & 4 != 0

            when 2 # PRIORITY
              raise ProtocolError, 'invalid PRIORITY' unless id > 0 && payload.bytesize == 5
              raise ProtocolError, 'self-dependent stream' if (payload.unpack1('N') & 0x7fffffff) == id

            when 3 # RST_STREAM
              raise ProtocolError, 'invalid RST_STREAM' unless id > 0 && id < @next_id && payload.bytesize == 4

              if stream
                error = payload.unpack1('N')
                stream.reset_queued = true

                if error.zero? && stream.remote_end
                  # A peer may finish a response before accepting the whole
                  # request body (RFC 9113, 8.1). Preserve that response while
                  # releasing the caller from upload flow-control waits.
                  stream.upload_stopped = true
                else
                  stream.error = ProtocolError.new("HTTP/2 stream reset (#{error})")
                end
              end

            when 4 # SETTINGS
              unless id.zero? && payload.bytesize % 6 == 0
                raise ProtocolError, 'invalid SETTINGS frame'
              end

              if flags & 1 != 0
                raise ProtocolError, 'SETTINGS ACK has payload' unless payload.empty?
              end

              payload.unpack('nN' * (payload.bytesize / 6)).each_slice(2) do |setting, value|
                case setting
                when 2 then raise ProtocolError, 'server sent ENABLE_PUSH'
                when 3 then @peer_limit = [value, 100].min
                when 4
                  raise ProtocolError, 'invalid initial window' if value > 0x7fffffff

                  delta = value - @initial_window

                  @reservations.each_value do |s|
                    s.send_window += delta
                    raise ProtocolError, 'stream window overflow' if s.send_window > 0x7fffffff
                  end

                  @initial_window = value
                when 5
                  raise ProtocolError, 'invalid maximum frame size' unless (16_384..16_777_215).cover?(value)

                  @max_frame = [value, 65_536].min
                end
              end

              @settings_received = true
              output << [4, 1, 0, ''.b]

            when 5
              raise ProtocolError, 'server push was disabled'

            when 6 # PING
              raise ProtocolError, 'invalid PING frame' unless id.zero? && payload.bytesize == 8
              output << [6, 1, 0, payload] if flags & 1 == 0

            when 7 # GOAWAY
              raise ProtocolError, 'invalid GOAWAY' unless id.zero? && payload.bytesize >= 8

              last, error = payload.unpack('NN')
              last &= 0x7fffffff
              @draining = true

              @reservations.each_value do |s|
                s.error = ProtocolError.new("HTTP/2 GOAWAY (#{error})") if !s.id || s.id > last || error != 0
              end

            when 8 # WINDOW_UPDATE
              raise ProtocolError, 'invalid WINDOW_UPDATE' unless payload.bytesize == 4

              increment = payload.unpack1('N') & 0x7fffffff
              raise ProtocolError, 'zero window increment' if increment.zero?

              if id.zero?
                @send_window += increment
                raise ProtocolError, 'connection window overflow' if @send_window > 0x7fffffff
              elsif stream
                stream.send_window += increment
                raise ProtocolError, 'stream window overflow' if stream.send_window > 0x7fffffff
              elsif id >= @next_id
                raise ProtocolError, 'WINDOW_UPDATE on idle stream'
              end

            when 9 # CONTINUATION
              raise ProtocolError, 'unexpected CONTINUATION' unless @continuation && id == @continuation[0]
              @continuation[1] << payload
              raise ProtocolError, 'encoded headers too large' if @continuation[1].bytesize > 65_536
              finish_headers(stream) if flags & 4 != 0
            end

            output
          end

          def unpad(payload, flags)
            return payload.dup if flags & 8 == 0
            padding = payload.getbyte(0)
            raise ProtocolError, 'invalid padding' unless padding && padding < payload.bytesize
            payload.byteslice(1, payload.bytesize - padding - 1)
          end

          def finish_headers(stream)
            _, block, ended = @continuation

            @continuation = nil
            headers = @decoder.decode(block)

            return unless stream && !stream.cancelled

            raise ProtocolError, 'headers after stream end' if stream.remote_end

            regular = false
            statuses = []

            headers.each do |name,value|
              unless name.match?(/\A:?[!#$%&'*+.^_`|~0-9a-z-]+\z/) && !value.match?(/[\x00\r\n]/)
                raise ProtocolError, 'invalid response field'
              end

              if name.start_with?(':')
                if regular || name != ':status' || stream.headers
                  raise ProtocolError, 'invalid response pseudo-header'
                end

                statuses << value
              else
                regular = true

                if %w[connection proxy-connection keep-alive upgrade transfer-encoding].include?(name)
                  raise ProtocolError, 'connection-specific response header'
                end
              end
            end

            if stream.headers
              raise ProtocolError, 'trailers must end stream' unless ended

              headers.each { |name,value| (stream.trailers[name] ||= []) << value }
            else
              unless statuses.size == 1 && statuses[0].match?(/\A[1-5]\d\d\z/) && statuses[0] != '101'
                raise ProtocolError, 'invalid status'
              end

              lengths = headers.select { |name,_| name == 'content-length' }.map(&:last)

              unless lengths.empty? ||
                     (lengths.all? { |length| length.match?(/\A\d+\z/) } && lengths.uniq.size == 1)

                raise ProtocolError, 'invalid response Content-Length'
              end

              if statuses[0].start_with?('1')
                stream.informationals += 1

                raise ProtocolError, 'invalid informational response' if ended || stream.informationals > 10
                return
              end

              stream.headers = headers
            end
            stream.remote_end = true if ended
          end

          def validate_length(response, stream, length)
            return if stream.method == 'HEAD' || %w[204 304].include?(response.code)
            raise ProtocolError, 'response Content-Length mismatch' if length && length != stream.received
          end

          def acquire_writer(operation)
            operation.check!
            deadline = Clock.now + operation.options[:write_timeout]

            until @writer.try_lock
              raise Net::WriteTimeout, 'HTTP/2 writer acquisition timeout' if Clock.now >= deadline
              Wait.pause(operation)
            end

            begin
              operation.check!
              yield
            ensure
              @writer.unlock
            end
          end

          def write_frame(type, flags, id, payload, operation)
            acquire_writer(operation) { write_frame_unlocked(type, flags, id, payload, operation) }
          end

          def write_frame_unlocked(type, flags, id, payload, operation)
            size = payload.bytesize
            bytes = [size >> 16, (size >> 8) & 255, size & 255, type, flags, id].pack('CCCCCN') + payload
            write_bytes(bytes, operation)
          end

          def write_bytes(bytes, operation)
            offset = 0
            deadline = Clock.now + operation.options[:write_timeout]

            while offset < bytes.bytesize
              # Once emission starts, finish the frame (or entire header block)
              # before observing request cancellation. A healthy shared connection
              # must not be corrupted by abandoning a partial frame or CONTINUATION.
              now = Clock.now

              raise RequestTimeout, 'request deadline exceeded' if operation.deadline && now >= operation.deadline
              raise Net::WriteTimeout, 'HTTP/2 write timeout' if now >= deadline

              n = @socket.write_nonblock(bytes.byteslice(offset, bytes.bytesize), exception: false)
              wait = [deadline - now, 0.02, operation.deadline && operation.deadline - now].compact.min

              case n
              when Integer then offset += n
              when :wait_readable then @socket.to_io.wait_readable(wait)
              when :wait_writable then @socket.to_io.wait_writable(wait)
              end
            end
          rescue Exception
            # A partially emitted frame cannot be discarded independently.
            close
            raise
          end
        end
      end

      private_constant :HTTP2
    end
  end
end
```
