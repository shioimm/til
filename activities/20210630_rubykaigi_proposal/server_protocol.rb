require_relative './protocols/duck/parser'
require_relative './protocols/rubylike/parser'
require_relative './config/const'

class ServerProtocol
  attr_reader :method, :path

  def initialize(protocol)
    @parser = Object.const_get("#{protocol}::Parser").new
    @method = nil
    @path   = nil
    @status_codes = nil

    initialize_status_codes!
  end

  def receive!(message)
    message = @parser.parse!(message)
    @method = message[:method]
    @path = message[:path]
  end

  def http_status_code(status)
    @status_codes[status]
  end

  private

    def initialize_status_codes!
      if @status_codes.nil?
        adding_statuses = case @parser
                          when Duck::Parser
                            { 600 => 'You are the uggly duckling' }
                          when RubyLike::Parser
                            { 600 => 'Are you a Ruby programmer' }
                          end

        @status_codes = Config::HTTP_STATUS_CODES.dup
        @status_codes.merge!(adding_statuses)
      end
    end
end
