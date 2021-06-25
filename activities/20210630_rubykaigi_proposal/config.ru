require 'rack'
require_relative './server'

class App
  def call(env)
    if env['REQUEST_METHOD'] != 'OTHER'
      [
        200,
        { 'Content-Type' => 'text/html' },
        ["<div><h1>Hello</h1><p>This app is running on Ruby Protocol.</p></div>"]
      ]
    else
      [
        600,
        { 'Content-Type' => 'text/html' },
        ["Are you a Ruby programmer?"]
      ]
    end
  end
end

run App.new
