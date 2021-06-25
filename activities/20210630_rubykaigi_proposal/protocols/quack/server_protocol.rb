require_relative './parser'

module Quack
  class ServerProtocol
    attr_reader :method, :path

    def initialize
      @parser = Quack::Parser.new
      @method = nil
      @path   = nil
    end

    def receive!(message)
      message = @parser.parse!(message)
      @method = message[:method]
      @path = message[:path]
    end
  end
end
