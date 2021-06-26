require 'rack'
require_relative './server'

class App
  def call(env)
    case env['REQUEST_METHOD']
    when 'GET'
      [
        200,
        { 'Content-Type' => 'text/html' },
        ["Hello, This app is running on Ruby Protocol."]
      ]
    when 'OTHER'
      [
        600,
        { 'Content-Type' => 'text/html' },
        ["Are you a Ruby programmer?"]
      ]
    end
  end
end

run App.new
