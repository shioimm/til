Protocol.define(:ruby) do |message|
  using Module.new {
    refine String do
      def get
        Protocol.request.path do |message|
          /['"](?<path>.+)['"]/.match(message)[:path]
        end

        Protocol.request.http_method { |_| "GET" }
      end
    end
  }

  instance_eval message

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
