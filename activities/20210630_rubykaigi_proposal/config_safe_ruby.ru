require 'rack'
require_relative './server'
require_relative './protocol'

Protocol.use(:safe_ruby)

class App
  def call(env)
    case env['REQUEST_METHOD']
    when 'GET'
      case env['PATH_INFO']
      when '/posts'
        if URI.decode_www_form_component(env['QUERY_STRING']) == "user_id=2"
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

run App.new
