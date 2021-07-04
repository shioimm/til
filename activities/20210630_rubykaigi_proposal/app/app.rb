require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'post'
require_relative '../server'
require_relative '../protocol'

Protocol.use(:safe_ruby_with_sinatra)

class App < Sinatra::Base
  set :server, :server
  set :port, 9292

  get '/posts' do
    @posts = params[:user_id] ? Post.where(user_id: params[:user_id]) : Post.all

    erb :index
  end

  post '/posts' do
    Post.new(user_id: params[:user_id], body: params[:body])

    redirect to('/posts')
  end

  run! if app_file == $0
end
