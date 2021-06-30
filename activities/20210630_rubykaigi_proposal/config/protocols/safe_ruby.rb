Protocol.define(:safe_ruby) do
  request.path do |message|
    /['"](?<path>.+)['"]/.match(message)[:path]
  end

  request.http_method do |message|
    using Module.new {
      refine String do
        def get = 'GET'
      end
    }

    request_path.get
  end

  app.call do |env|
    case env['REQUEST_METHOD']
    when 'GET'
      case env['PATH_INFO']
      when '/posts'
        posts = ['I love Ruby', 'I love RubyKaigi']

        [
          200,
          { 'Content-Type' => 'text/html' },
          ["#{posts}"]
        ]
      end
    end
  end
end
