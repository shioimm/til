require 'rack/handler'
require 'rack/handler/puma'

module Rack
  module Handler
    class Protoycol
      CONFIG = ::Protoycol::Config
      def self.run(app, options = {})
        if child_pid = fork
          puts "Protoycol starts Puma in single mode, listening on unix://#{::Protoycol::Config::UNIX_SOCKET_PATH}"
          Rack::Handler::Puma.run(app, { Host: ::Protoycol::Config::UNIX_SOCKET_PATH, Silent: true })
          Process.waitpid(child_pid)
        else
          environment  = ENV['RACK_ENV'] || 'development'
          default_host = environment == 'development' ? ::Protoycol::Config::LOCALHOST : ::Config::DEFAULT_HOST

          host = options.delete(:Host) || default_host
          port = options.delete(:Port) || ::Protoycol::Config::DEFAULT_PORT
          args = [host, port]

          ::Protoycol::Proxy.new(host, port).start
        end
      end
    end

    register :protoycol, Protoycol
  end
end
