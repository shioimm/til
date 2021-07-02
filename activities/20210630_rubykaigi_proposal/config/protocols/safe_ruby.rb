PARSER_REGEX = /["'](?<path>\/.*)["']\.(?<method>[A-z]+)/
QUERY_REGEX  = /query?.*\{(?<query>.*)\}/

Protocol.define(:safe_ruby) do |message|
  parsed_message = PARSER_REGEX.match message
  path   = parsed_message[:path]
  method = parsed_message[:method]
  query  = QUERY_REGEX.match message

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

  app.call do |env|
    case env['REQUEST_METHOD']
    when 'GET'
      case env['PATH_INFO']
      when '/posts'
        if URI.decode_www_form_component(env['QUERY_STRING']) == "user_id=1"
          [
            200,
            { 'Content-Type' => 'text/html' },
            ["I love RubyKaigi"]
          ]
        else
          [
            200,
            { 'Content-Type' => 'text/html' },
            ["'I love Ruby', 'I love RubyKaigi'"]
          ]
        end
      end
    end
  end
end
