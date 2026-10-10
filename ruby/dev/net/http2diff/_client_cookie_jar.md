## client/cookie_jar.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client/cookie_jar.rb

```ruby
# frozen_string_literal: true

require 'time'

module Net
  class HTTP
    class Client
      class CookieJar
        Cookie = Struct.new(:name, :value, :domain, :path, :secure, :host_only, :expires, :sequence)

        def initialize(max_cookies: 3000)
          @max = Integer(max_cookies)
          raise ArgumentError, 'max_cookies must be positive' unless @max > 0
          @mutex, @cookies, @sequence = Mutex.new, {}, 0
        end

        # Client::CookieJar#store
        def store(uri, response)
          uri = URI(uri.to_s)
          (response.get_fields('set-cookie') || []).each { |line| store_line(uri, line) }
          self
        end

        def header(uri)
          uri = URI(uri.to_s)
          @mutex.synchronize do
            @cookies.delete_if { |_, c| c.expires && c.expires <= Time.now }

            @cookies.values.select { |c|
              (!c.secure || uri.scheme == 'https') &&
                domain_match?(uri.hostname.downcase, c) &&
                (uri.path == c.path ||
                 (uri.path.start_with?(c.path) && (c.path.end_with?('/') || uri.path[c.path.length] == '/')))
            }.sort_by { |c|
              [-c.path.length, c.sequence]
            }.map { |c|
              "#{c.name}=#{c.value}"
            }.join('; ')
          end
        end

        def clear
          @mutex.synchronize { @cookies.clear }
          self
        end

        private

        def domain_match?(host, cookie)
          host == cookie.domain || (!cookie.host_only && host.end_with?(".#{cookie.domain}"))
        end

        def store_line(uri, line)
          return if line.bytesize > 4096 || line.match?(/[\r\n\x00]/)

          first, *attributes = line.split(';')
          name, value = first.to_s.strip.split('=', 2)
          return unless value && name.match?(/\A[!#$%&'*+.^_`|~0-9A-Za-z-]+\z/)

          attrs = attributes.each_with_object({}) { |part, h| k,v = part.strip.split('=',2); h[k.downcase] = v }
          host = uri.hostname.downcase
          domain = attrs['domain'] ? attrs['domain'].sub(/\A\./, '').downcase : host
          # Conservatively reject parent-domain cookies without a public-suffix list.
          # An exact Domain can still scope to descendants of this response host.
          return if domain != host

          path = attrs['path']
          path = uri.path.sub(%r{/[^/]*\z}, '') unless path && path.start_with?('/')
          path = '/' if !path || path.empty?
          secure = attrs.key?('secure')

          return if secure && uri.scheme != 'https'
          return if name.start_with?('__Secure-') && !secure
          return if name.start_with?('__Host-') && (!secure || attrs.key?('domain') || path != '/')

          expires = Time.httpdate(attrs['expires']) rescue nil
          expires = Time.now + attrs['max-age'].to_i if attrs['max-age'] && attrs['max-age'].match?(/\A-?\d+\z/)

          @mutex.synchronize do
            @sequence += 1
            key = [name, domain, path]

            if expires && expires <= Time.now
              @cookies.delete(key)
            else
              @cookies[key] = Cookie.new(
                name,
                value,
                domain,
                path,
                secure,
                !attrs.key?('domain'),
                expires,
                @sequence
              )

              @cookies.shift while @cookies.length > @max
            end
          end
        end
      end
    end
  end
end
```
