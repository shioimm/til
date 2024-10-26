# https://github.com/hogelog/kaigionrails-2024-rack-workshop/blob/main/02-middleware.md

require "rack/runtime"
require "rack/auth/basic"

class App
  def call(env)
    [200, {}, ["hello"]]
  end
end

class Middleware
  def initialize(app, name)
    @app = app
    @name = name
  end

  def call(env)
    status, headers, body = @app.call(env)
    headers["hello"] = @name
    [status, headers, body]
  end
end

use Middleware, "rails"
use Rack::Runtime
use Rack::Auth::Basic do |username, password|
  username == "rubyist" && password == "onrack"
end
run App.new
