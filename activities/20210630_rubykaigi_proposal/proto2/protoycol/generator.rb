require 'fileutils'

module Protoycol
  class Generator
    class << self
      def execute!(type, name:, dir:)
        case type
        when :app
          generate_app!(name, dir)
        when :protocol
          generate_protocol!(name, dir)
        else
          raise StandardError, "Unknown type"
        end
      end

      def generate_app!(name, dir)
        new(name, dir).generate_app_file!
      end

      def generate_protocol!(name, dir)
        new(name, dir).generate_protocol_file!
      end
    end

    def initialize(name, dir)
      @name = name.to_s
      @dir  = dir
    end

    def generate_app_file!
      File.open("#{dir}/config_#{name}.ru", "w") { |f| f.print app_template_text }
    end

    def generate_protocol_file!
      if Dir.glob(protocol_dir = "#{dir}/protocols").empty?
        FileUtils.mkdir_p(protocol_dir)
      end

      File.open("#{protocol_dir}/#{name}.rb", "w") { |f| f.print protocol_template_text }
    end

    private

      attr_reader :name, :dir

      def protocol_template_text
        <<~TEXT
          Protoycol::Protocol.define(:#{name}) do
            # You can define your additional request methods:
            # additional_request_methods <YOUR ORIGINAL METHODS>

            # You can define your own response status code:
            # define_status_codes(
            #   <YOUR ORIGINAL STATUS CODE NUMBER> => <YOUR ORIGINAL STATUS CODE VALUE>
            # )

            # Define how you parse request path from request message
            request.path do |message|
              # WIP
            end

            # Define how you parse query from request message
            request.query do |message|
              # WIP
            end

            # Define how you parse query from request message
            request.http_method do |message|
              # WIP
            end
          end
        TEXT
      end

      def app_template_text
        <<~TEXT
          require 'rack'
          require_relative './protoycol'

          # You specify the protocol in your app
          Protoycol::Protocol.use(:#{name})

          class App
            def call(env)
              # You can define your app on request method, request path, request query etc
              case env['REQUEST_METHOD']
              when 'GET'
                [
                  200,
                  { 'Content-Type' => 'text/html' },
                  ["Hello, This app is running by :#{name} protocol."]
                ]
              end
            end
          end

          run App.new
        TEXT
      end
  end
end
