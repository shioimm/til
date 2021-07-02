require 'rack'
require_relative './server'
require_relative './protocol'

Protocol.use(:safe_ruby)
# Protocol.use(:ruby)
# Protocol.use(:rubylike)
# Protocol.use(:duck)

run Protocol.app.new
