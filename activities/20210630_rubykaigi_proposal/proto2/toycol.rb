require_relative 'toycol/config/const'
require_relative 'toycol/helper'
require_relative 'toycol/protocol'
require_relative 'toycol/proxy'
require_relative 'rack/handler/toycol'

Dir["#{__dir__}/protocols/*.rb"].sort.each { |f| require f }

module Toycol
  class Error < StandardError; end
  class UnauthorizedMethodError < Error; end
end
