# https://github.com/hogelog/kaigionrails-2024-rack-workshop/blob/main/01-app.md

require "rack/request"
require "rack/response"

class App
  def call(env)
    method = env["REQUEST_METHOD"]
    path = env["PATH_INFO"]
    # body = case path
    #        when "/"      then "It works!"
    #        when "/hello" then "Hello foobar!"
    #        end
    request = Rack::Request.new(env)
    headers = { "content-type" => "text/plain" }

    case [request.request_method, request.path_info]
    in ["GET", "/"]      then  Rack::Response.new("It works!", 200, headers).finish
    in ["GET", "/hello"] then  Rack::Response.new("Hello!", 200, headers).finish
    end
  end
end

run App.new
