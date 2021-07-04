module SafeRuby
  PARSER_REGEX = /["'](?<path>\/.*)["']\.(?<method>[A-z]+)/
  QUERY_REGEX  = /query?.*\{(?<query>.*)\}/
end

Protocol.define(:safe_ruby) do |message|
  parsed_message = SafeRuby::PARSER_REGEX.match message
  path   = parsed_message[:path]
  method = parsed_message[:method]
  query  = SafeRuby::QUERY_REGEX.match message

  using Module.new {
    refine String do
      def get(query: nil)
        query = if query
                  query[:query].split(',').map{ |q| q.scan(/\w+/).join('=') }.join('&')
                end

        Protocol.request.query { query }
        Protocol.request.http_method { 'GET' }
      end
    end
  }

  request.path { path }

  request_path.public_send(method, query: query)
end
