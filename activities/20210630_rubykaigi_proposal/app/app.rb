require 'sinatra'
require 'sinatra/reloader'
require_relative 'post'
require_relative '../server'

get '/posts' do
  @posts = params[:user_id] ? Post.where(user_id: params[:user_id]) : Post.all
  erb :index
end
