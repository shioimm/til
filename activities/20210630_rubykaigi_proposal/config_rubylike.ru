require 'rack'
require_relative './server'
require_relative './protocol'

Protocol.use(:rubylike)

class App
  def call(env)
    case env['REQUEST_METHOD']
    when 'GET'
      [
        200,
        { 'Content-Type' => 'text/html' },
        ["Hello, This app is running on Ruby like protocol."]
      ]
    when 'OTHER'
      [
        600,
        { 'Content-Type' => 'text/html' },
        ["I'm afraid you are not a Ruby programmer..."]
      ]
    end
  end
end

run App.new
