require_relative './config/const'

class Protocol
  @definements   = {}
  @protocol_name = nil
  @http_status_codes    = Config::DEFAULT_HTTP_STATUS_CODES.dup
  @http_request_methods = Config::DEFAULT_HTTP_REQUEST_METHODS.dup
  @defined_status_codes = nil
  @additional_request_methods = nil

  class << self
    def define(protocol_name = nil, &block)
      @definements[protocol_name] = block
    end

    def run!(message)
      @request_message = message

      if block = @definements[@protocol_name]
        instance_eval(&block)
      end
    end

    def use(protocol_name)
      @protocol_name ||= protocol_name
    end

    def define_status_codes(**defined_status_codes)
      @defined_status_codes ||= defined_status_codes
    end

    def additional_request_methods(*additional_request_methods)
      @additional_request_methods ||= additional_request_methods
    end

    def status_message(status)
      @http_status_codes.merge!(@defined_status_codes) if @defined_status_codes
      @http_status_codes[status]
    end

    def app
      @app ||= Class.new {
        def self.call(&block)
          @call = block
        end

        def call(env)
          self.class.instance_variable_get("@call").call(env)
        end
      }
    end

    def request
      @request ||= Class.new {
        def self.path(&block)
          @path = block
        end

        def self.http_method(&block)
          @http_method = block
        end
      }
    end

    def request_path
      request_path = request.instance_variable_get("@path").call(request_message)

      if request_path.size >= 2048
        raise "This request path is too long"
      elsif request_path.scan(/[\/\w\d\-\_]/).size < request_path.size
        raise "This request path contains disallowed character"
      else
        request_path
      end
    end

    def request_method
      @http_request_methods.concat @additional_request_methods if @additional_request_methods

      request_method = request.instance_variable_get("@http_method").call(request_message)

      if @http_request_methods.include? request_method
        request_method
      else
        raise "This request method is undefined"
      end
    end

    private

      attr_reader :request_message
  end
end

Dir['./config/protocols/*.rb'].sort.each { |f| require f }
