## client.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client/request.rb

```ruby
# frozen_string_literal: true
require 'json'
require 'securerandom'

module Net
  class HTTP
    class Client
      class Body
        attr_reader :length

        def initialize(source)
          @position = nil
          @source = source.is_a?(String) ? source.b.dup.freeze : source
          @position = source.pos if source && !source.is_a?(String) && source.respond_to?(:pos) && source.respond_to?(:seek)
          @length = if @source.nil?
            0
          elsif @source.is_a?(String)
            @source.bytesize
          elsif @position && source.respond_to?(:size)
            source.size - @position
          end
          @mutex = Mutex.new
          @used = false
        rescue IOError, Errno::ESPIPE
          @position = @length = nil
          @mutex = Mutex.new
          @used = false
        end

        def replayable?
          @source.nil? || @source.is_a?(String) || !@position.nil?
        end

        def each
          return enum_for(:each) unless block_given?
          raise IOError, 'request body is already in use' unless @mutex.try_lock
          begin
            if @used && !replayable?
              raise IOError, 'request body cannot be replayed'
            end
            @source.seek(@position) if @used && @position
            @used = true
            total = 0
            emit = proc do |chunk|
              total += chunk.bytesize
              raise IOError, 'request body length changed during upload' if @length && total > @length
              yield chunk
            end
            if @source.is_a?(String)
              emit.call(@source) unless @source.empty?
            elsif @source.respond_to?(:read)
              while (chunk = @source.read(16_384)) && !chunk.empty?
                emit.call(String(chunk).b)
              end
            elsif @source
              @source.each { |chunk| emit.call(String(chunk).b) unless chunk.empty? }
            end
            raise IOError, 'request body length changed during upload' if @length && total != @length
          ensure
            @mutex.unlock
          end
        end
      end

      class MultipartBody
        attr_reader :length, :boundary
        def initialize(parts, legacy_options: nil)
          @boundary = ((legacy_options && legacy_options[:boundary]) || "net-http-#{SecureRandom.hex(16)}").to_s.dup.freeze
          unless @boundary.match?(/\A[0-9A-Za-z'()+_,.\/:=? -]{1,70}\z/) && !@boundary.end_with?(' ')
            raise ArgumentError, 'invalid multipart boundary'
          end
          charset = legacy_options && legacy_options[:charset]
          @parts = parts.map do |name, value, options|
            name = quoted(name, charset)
            type = nil
            if legacy_options
              options ||= {}
              filename = options.key?(:filename) ? options[:filename] : (File.basename(value.to_path) if value.respond_to?(:to_path))
              source = value.respond_to?(:read) ? value : value.to_s
              disposition = +"form-data; name=\"#{name}\""
              disposition << "; filename=\"#{quoted(filename, charset)}\"" if filename
              type = (options[:content_type] || 'application/octet-stream').to_s if filename
            elsif value.is_a?(Hash)
              source = value.fetch(:body)
              disposition = "form-data; name=\"#{name}\"; filename=\"#{quoted(value.fetch(:filename))}\""
              type = value.fetch(:content_type, 'application/octet-stream').to_s
            else
              source = value.to_s
              disposition = "form-data; name=\"#{name}\""
              type = nil
            end
            raise ArgumentError, 'invalid multipart content type' if type && type.match?(/[\r\n]/)
            prefix = +"--#{@boundary}\r\nContent-Disposition: #{disposition}\r\n"
            prefix << "Content-Type: #{type}\r\n" if type
            [(prefix << "\r\n").b, Body.new(source)]
          end
          @ending = "--#{@boundary}--\r\n".freeze
          @length = @parts.all? { |_, body| body.length } && @parts.inject(@ending.bytesize) { |n, (prefix, body)| n + prefix.bytesize + body.length + 2 }
          @length = nil unless @length
        end
        def replayable?; @parts.all? { |_, body| body.replayable? }; end
        def each
          return enum_for(:each) unless block_given?
          @parts.each do |prefix, body|
            yield prefix
            body.each { |chunk| yield chunk }
            yield "\r\n"
          end
          yield @ending
        end
        private
        def quoted(value, charset = nil)
          value = value.to_s
          value = value.encode(charset, fallback: ->(c) { "&##{c.encode('UTF-8').ord};" }) if charset
          raise ArgumentError, 'invalid multipart name' if value.match?(/[\r\n]/)
          value.gsub(/["\\]/) { |c| "\\#{c}" }.b
        end
      end

      # Header and URL snapshots are immutable. Caller-owned body IO is not closed.
      class Request
        attr_reader :method, :uri, :headers, :options

        # Client::Request#initialize
        def initialize(method, uri, headers: {}, body: nil, **options)
          # HTTPメソッドを大文字に揃えて検証
          @method = method.to_s.upcase.freeze
          raise ArgumentError, 'invalid HTTP method' unless @method.match?(/\A[!#$%&'*+.^_`|~0-9A-Z-]+\z/)

          # uriを文字列にしてからURIオブジェクトへ変換
          @uri = URI(uri.to_s).dup

          # スキームがhttpまたはhttps、ホストがあり、URLにユーザー名・パスワードの情報がないことを検証
          unless %w[http https].include?(@uri.scheme) && @uri.host && !@uri.userinfo
            raise ArgumentError, 'an absolute HTTP(S) URL without userinfo is required'
          end

          # @uriを整える
          @uri.fragment = nil
          @uri.instance_variables.each do |ivar|
            value = @uri.instance_variable_get(ivar)
            value.freeze if value.is_a?(String) # URIオブジェクトが持つインスタンス変数を調べ、文字列の値をfreeze
          end
          @uri.freeze

          # @headers, @body, @optionsを整える
          @headers = self.class.headers(headers)
          @body = body.is_a?(Body) || body.is_a?(MultipartBody) ? body : Body.new(body)
          @options = self.class.snapshot(options)

          # --- @headersの検証 ---
          if @headers.key?('host') && @headers['host'].size != 1
            raise ArgumentError, 'Host must have a single value'
          end

          if @headers.key?('content-length')
            lengths = @headers['content-length']

            unless lengths.size == 1 && # 値が1つだけ
                   lengths[0].match?(/\A\d+\z/) && # 値が数字だけの文字列
                   @body.length && lengths[0].to_i == @body.length # 指定値と実際のボディの長さが一致
              raise ArgumentError, 'Content-Length must match the request body'
            end
          end

          if @headers.key?('transfer-encoding')
            # Transfer-Encodingの指定は禁止
            raise ArgumentError, 'request framing is managed by Client'
          end
          # ----------------------

          # メソッドがHEADまたはTRACEかつボディがある場合はエラー
          if %w[HEAD TRACE].include?(@method) && @body.length != 0
            raise ArgumentError, "#{@method} does not accept a body"
          end
          freeze
        end

        def self.snapshot(value)
          case value
          when URI::Generic
            copy = URI(value.to_s)
            copy.instance_variables.each do |name|
              component = copy.instance_variable_get(name)
              component.freeze if component.is_a?(String)
            end
            copy.freeze
          when Hash then value.each_with_object({}) { |(k,v), h| h[k] = snapshot(v) }.freeze
          when Array then value.map { |v| snapshot(v) }.freeze
          when String then value.dup.freeze
          else value
          end
        end
        def self.headers(headers)
          headers.each_with_object({}) do |(key, values), result|
            name = key.to_s.downcase
            raise ArgumentError, 'invalid header name' unless name.match?(/\A[!#$%&'*+.^_`|~0-9a-z-]+\z/)
            result[name.freeze] = Array(values).map do |value|
              text = value.to_s
              raise ArgumentError, 'invalid header value' if text.match?(/[\x00-\x08\x0a-\x1f\x7f]/)
              text.dup.freeze
            end.freeze
          end.freeze
        end
        def with(method: @method, uri: @uri, headers: @headers, body: @body, **options)
          self.class.new(method, uri, headers: headers, body: body, **@options.merge(options))
        end
        def replayable?; @body.replayable?; end
        def body_length; @body.length; end
        def each_body_chunk(&block); @body.each(&block); end
        def body; @body; end
        def origin; [@uri.scheme, @uri.hostname.downcase, @uri.port]; end
        def request_target; @uri.request_uri; end
      end

      # Bridges a lazy body enumerator to the upstream HTTP/1 request writer.
      class BodyReader
        def initialize(body)
          @closed = @started = false
          @enum = Enumerator.new do |output|
            catch(:body_reader_closed) do
              body.each do |chunk|
                output << chunk
                throw :body_reader_closed if @closed
              end
            end
          end
          @buffer = ''.b
          @done = false
        end
        def read(length = nil, output = nil)
          raise IOError, 'body reader is closed' if @closed
          while !@done && (!length || @buffer.bytesize < length)
            begin
              @started = true
              @buffer << @enum.next
            rescue StopIteration
              @done = true
            rescue Exception
              @done = true
              raise
            end
          end
          result = @buffer.slice!(0, length || @buffer.bytesize)
          return nil if result.empty? && @done && length
          output ? output.replace(result) : result
        end
        def close
          return if @closed
          @closed = true
          # Resume only to unwind the suspended yield and release the body's
          # ownership lock; never read another chunk during cancellation.
          @enum.next if @started && !@done
        rescue StopIteration
          nil
        ensure
          @done = true
          @buffer.clear
        end
      end
      private_constant :Body, :MultipartBody, :BodyReader
    end
  end
end
```
