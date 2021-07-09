module Protoycol
  class Protocol
    @definements   = {}
    @protocol_name = nil
    @http_status_codes    = Protoycol::Config::DEFAULT_HTTP_STATUS_CODES.dup
    @http_request_methods = Protoycol::Config::DEFAULT_HTTP_REQUEST_METHODS.dup
    @defined_status_codes = nil
    @additional_request_methods = nil

    class << self
      def define(protocol_name = nil, &block)
        @definements[protocol_name] = block
      end

      def run!(message)
        @request_message = message.chomp

        if block = @definements[@protocol_name]
          instance_exec(@request_message, &block)
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

      def request
        @request ||= Class.new {
          def self.path(&block)
            @path = block
          end

          def self.query(&block)
            @query = block
          end

          def self.http_method(&block)
            @http_method = block
          end

          def self.input(&block)
            @input = block
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

      def query
        if (parse_query_block = request.instance_variable_get("@query"))
          parse_query_block.call(request_message)
        end
      end

      def input
        if (parsed_input_block = request.instance_variable_get("@input"))
          parsed_input_block.call(request_message)
        end
      end

      private

      attr_reader :request_message
    end
  end
end
