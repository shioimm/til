require_relative 'protoycol/config/const'
require_relative 'protoycol/helper'
require_relative 'protoycol/protocol'
require_relative 'protoycol/proxy'
require_relative 'rack/handler/protoycol'

Dir["#{__dir__}/protocols/*.rb"].sort.each { |f| require f }

module Protoycol
  class Error < StandardError; end
  class UnauthorizedMethodError < Error; end
end
