require_relative './config/const'

class Protocol
  @@definements = {}
  @@protocol_name = nil

  class << self
    def define(protocol_name = nil, &block)
      @@definements[protocol_name] = block
    end

    def run!(message)
      if block = @@definements[@@protocol_name]
        instance_exec(message, &block)
      end
    end

    def use(protocol_name)
      @@protocol_name = protocol_name
    end

    def app
      @@app ||= Class.new {
        def self.call(&block)
          @call = block
        end

        def call(env)
          self.class.instance_variable_get("@call").call(env)
        end
      }
    end

    def request
      @@request ||= Class.new {
        def self.path(&block)
          @path = block
        end

        def self.http_method(&block)
          @http_method = block
        end

        def self.parse(&block)
          @parse = block
        end
      }
    end

    def path(message)
      request.instance_variable_get("@path").call(message)
    end

    def http_method(message)
      request.instance_variable_get("@http_method").call(message)
    end

    def define_status_codes(defined_status_codes)
      @defined_status_codes = defined_status_codes
    end

    def status_message(status)
      if @status_codes.nil?
        @status_codes = Config::DEFAULT_HTTP_STATUS_CODES.dup
        @status_codes.merge!(@defined_status_codes) if @defined_status_codes
      end

      @status_codes[status]
    end
  end
end

Dir['./config/protocols/*.rb'].sort.each { |f| require f }
