require 'rack'
require_relative 'toycol'

Toycol::Protocol.use(:duck)

class App
  def call(env)
    case env['REQUEST_METHOD']
    when 'GET'
      case env['PATH_INFO']
      when '/posts'
        if env['QUERY_STRING'] == "user_id=1"
          return [
            200,
            { 'Content-Type' => 'text/html' },
            ["quack quack, I am the No.1 duck"]
          ]
        end
        [
          200,
          { 'Content-Type' => 'text/html' },
          ["quack quack, quack quack, quack, quack"]
        ]
      when '/'
        [
          200,
          { 'Content-Type' => 'text/html' },
          ["Hello, This app is running on Sample duck protocol."]
        ]
      end
    when 'CRY'
      [
        600,
        { 'Content-Type' => 'text/html' },
        ["Sorry, this application is only for ducks..."]
      ]
    end
  end
end

run App.new
