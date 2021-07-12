module SafeRuby
  PARSER_REGEX = /["'](?<path>\/.*)["']\.(?<method>[A-z]+)/
  QUERY_REGEX  = /query?.*\{(?<query>.*)\}/
  INPUT_REGEX  = /input?.*(?<input>{.*\})/
end

Toycol::Protocol.define(:safe_ruby) do |message|
  using Module.new {
    refine String do
      def get(options = {})
        Toycol::Protocol.request.query { options[:query] } if options[:query]
        Toycol::Protocol.request.http_method { 'GET' }
      end

      def post(options = {})
        Toycol::Protocol.request.input { options[:input] } if options[:input]
        Toycol::Protocol.request.http_method { 'POST' }
      end

      def parse_as_queries
        split(',').map { |str| str.scan(/\w+/).join('=') }
      end

      def parse_as_inputs
        split(',').map { |str| str.split(':').map { |s| s.strip! && s.gsub(/['"]/, '') }.join('=') }
      end
    end
  }

  path, method = SafeRubyWithSinatra::PARSER_REGEX.match(message) { |m| [m[:path], m[:method]] }
  query = SafeRubyWithSinatra::QUERY_REGEX.match(message) { |m| m[:query].parse_as_queries }&.join('&')
  input = SafeRubyWithSinatra::INPUT_REGEX.match(message) { |m| m[:input].parse_as_inputs }&.join('&')
  args  = {}

  request.path { path }

  %i[query input].each do |k|
    if v = binding.local_variable_get(k)
      args[*k] = v
    end
  end

  request_path.public_send(method, args)
end
