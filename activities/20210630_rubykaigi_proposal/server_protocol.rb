require_relative './config/const'
require_relative './config/protocol'
require_relative './parser'

class ServerProtocol
  attr_reader :request_method, :path

  def initialize
    @parser            = ::Parser.new
    @request_method    = nil
    @path              = nil
    @http_status_codes = nil
    @http_methods      = nil

    initialize_http_methods!
    initialize_status_codes!
  end

  def receive!(message)
    @request_method = http_request_method(@parser.parse_request_method!(message))
    @path           = @parser.parse_request_path!(message)
  end

  def http_request_method(method_name = nil)
    @http_methods[method_name]
  end

  def http_status_code(status)
    @status_codes[status]
  end

  private

    def initialize_status_codes!
      if @status_codes.nil?
        @status_codes = Config::HTTP_STATUS_CODES.dup
        @status_codes.merge!(Config::DEFINED_STATUS_CODES) if Config::DEFINED_STATUS_CODES
      end
    end

    def initialize_http_methods!
      if @http_methods.nil?
        @http_methods = Config::HTTP_METHODS.dup
        @http_methods.merge!(Config::DEFINED_REQUEST_METHODS) if Config::DEFINED_REQUEST_METHODS
      end
    end
end
