Protocol.define(:safe_ruby) do |message|
  module SafeRuby
    PARSER_REGEX = /["'](?<path>\/.*)["']\.(?<method>[A-z]+)/
    QUERY_REGEX  = /query?.*\{(?<query>.*)\}/
    INPUT_REGEX  = /input?.*(?<input>{.*\})/
  end

  parsed_message = SafeRuby::PARSER_REGEX.match message
  path           = parsed_message[:path]
  method         = parsed_message[:method]
  parsed_query   = SafeRuby::QUERY_REGEX.match message
  query          = parsed_query[:query].split(',').map{ |q| q.scan(/\w+/).join('=') }.join('&') if parsed_query
  parsed_input   = SafeRuby::INPUT_REGEX.match message
  input          = parsed_input[:input]
  args           = {}

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
