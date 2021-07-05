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
        if env['QUERY_STRING'] == "user_id=2"
          [
            200,
            { 'Content-Type' => 'text/html' },
            ["User<2> I love RubyKaigi!"]
          ]
        else
          [
            200,
            { 'Content-Type' => 'text/html' },
            ["User<1> I love Ruby!", "User<2> I love RubyKaigi!"]
          ]
        end
      end
    when 'POST'
      input   = env['rack.input'].gets
      created = input.split('&').map { |str| str.split('=') }.to_h
      [
        201,
        { 'Content-Type' => 'text/html', 'Location' => '/posts' },
        ["User<1> I love Ruby!",
         "User<2> I love RubyKaigi!",
         "User<#{created['user_id']}> #{created['body']}"]
      ]
    end
  end
end

run App.new
