require 'rack'
require_relative './server'
require_relative './protocol'

run Protocol.app.new
