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
      }
    end

    def path(message)
      request_path = request.instance_variable_get("@path").call(message)

      if request_path.size >= 2048
        raise "This request path is too long"
      elsif request_path.scan(/[\/\w\d\-\_]/).size < request_path.size
        raise "This request path contains disallowed character"
      else
        request_path
      end
    end

    def http_method(message)
      if @http_methods.nil?
        @http_methods = Config::DEFAULT_HTTP_REQUEST_METHODS.dup
        @http_methods.concat @defined_request_methods if @defined_request_methods
      end

      request_method = request.instance_variable_get("@http_method").call(message)

      if @http_methods.include? request_method
        request_method
      else
        raise "This request method is undefined"
      end
    end

    def define_status_codes(**defined_status_codes)
      @defined_status_codes = defined_status_codes
    end

    def define_request_methods(*defined_request_methods)
      @defined_request_methods = defined_request_methods
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
