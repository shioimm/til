require 'rack'
require_relative './server'
require_relative './protocol'

Protocol.use(:duck)

run Protocol.app.new
