require 'rack'
require_relative './server'
require_relative './protocol'

Protocol.use(:ruby)

class App
  def call(env)
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

run App.new
