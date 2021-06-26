#Dir['./config/protocols/*.rb'].sort.each { |f| require f }
require_relative './config/const'

class Protocol
  def self.define(protocol_name, &block)
    instance_eval(&block)
  end

  def self.app
    @@app ||= Class.new {
      def self.call(&block)
        @call = block
      end

      def call(env)
        self.class.instance_variable_get("@call").call(env)
      end
    }
  end

  def self.request
    @@request ||= Class.new {
      def self.path(message, &block)
        @path = yield message
      end

      def self.http_method(message, &block)
        @http_method = yield message
      end
    }
  end

  def self.path
    request.instance_variable_get("@path")
  end

  def self.http_method
    request.instance_variable_get("@http_method")
  end

  def self.http_status_code(status)
    if @status_codes.nil?
      @status_codes = Config::HTTP_STATUS_CODES.dup
      @status_codes.merge!(Config::DEFINED_STATUS_CODES) if Config::DEFINED_STATUS_CODES
    end

    @status_codes[status]
  end
end
require_relative './config/protocols/rubylike'
