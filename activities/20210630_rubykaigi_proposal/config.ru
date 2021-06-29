require 'rack'
require_relative './server'
require_relative './protocol'

Protocol.use(:ruby)

run Protocol.app.new
