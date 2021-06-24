require 'rack/handler'

module Rack
  module Handler
    class Server
      def self.run(app, options = {})
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || 12345
        args = [host, port, app]
        ::Server.new(*args).start
      end
    end

    register :server, Server
  end
end
