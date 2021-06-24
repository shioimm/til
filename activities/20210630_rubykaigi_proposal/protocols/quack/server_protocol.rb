require_relative './parser.rb'

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
      @method, @path = message[:method], message[:path]
  end
end
