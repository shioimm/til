require 'rack'
require_relative './server'
require_relative './protocol'

Protocol.use(:rubylike)

run Protocol.app.new
