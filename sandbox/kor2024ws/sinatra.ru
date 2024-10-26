# https://github.com/hogelog/kaigionrails-2024-rack-workshop/blob/main/01-app.md

require "sinatra/base"

class App < Sinatra::Base
  get "/" do
    "It works"
  end

  get "/hello/:name" do
    "Hello #{params[:name]}"
  end
end

run App.new
