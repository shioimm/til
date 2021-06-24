require 'rack'
require_relative './server'

class App
  def call(env)
    if env['REQUEST_METHOD'] != 'CRY'
      [
        200,
        { 'Content-Type' => 'text/html' },
        ["<div><h1>Hello</h1><p>This app is running on Original Server Protocol.</p></div>"]
      ]
    else
      [
        600,
        { 'Content-Type' => 'text/html' },
        ["You are the ugly duckling."]
      ]
    end
  end
end

run App.new
