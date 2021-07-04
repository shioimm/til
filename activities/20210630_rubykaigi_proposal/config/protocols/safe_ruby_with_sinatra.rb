module SafeRubyWithSinatra
  PARSER_REGEX = /["'](?<path>\/.*)["']\.(?<method>[A-z]+)/
  QUERY_REGEX  = /query?.*\{(?<query>.*)\}/
  INPUT_REGEX  = /input?.*(?<input>{.*\})/
end

Protocol.define(:safe_ruby_with_sinatra) do |message|
  path, method = SafeRuby::PARSER_REGEX.match(message) { |m| [m[:path], m[:method]] }
  query = SafeRuby::QUERY_REGEX.match(message) { |m| m[:query].split(',').map{ |q| q.scan(/\w+/).join('=') }.join('&') }
  input = SafeRuby::INPUT_REGEX.match(message) { |m| m[:input] }
  args  = {}

  using Module.new {
    refine String do
      def get(options = {})
        Protocol.request.query { options[:query] } if options[:query]
        Protocol.request.http_method { 'GET' }
      end

      def post(options = {})
        Protocol.request.input { options[:input] } if options[:input]
        Protocol.request.http_method { 'POST' }
      end
    end
  }

  request.path { path }

  %i[query input].each do |k|
    if v = binding.local_variable_get(k)
      args[*k] = v
    end
  end

  request_path.public_send(method, args)
end
