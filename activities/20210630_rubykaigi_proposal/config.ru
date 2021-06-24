require 'rack'
require_relative './server'

class App
  def call(env)
    [
      200,
      { 'Content-Type' => 'text/html' },
      ["<div><h1>Hello</h1><p>This app is running on Original Server Protocol.</p></div>"]
    ]
  end
end

run App.new
