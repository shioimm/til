require 'rack/handler'
require 'rack/handler/puma'

module Rack
  module Handler
    class Toycol
      CONFIG = ::Toycol::Config
      def self.run(app, options = {})
        if child_pid = fork
          puts "Toycol starts Puma in single mode, listening on unix://#{::Toycol::Config::UNIX_SOCKET_PATH}"
          Rack::Handler::Puma.run(app, { Host: ::Toycol::Config::UNIX_SOCKET_PATH, Silent: true })
          Process.waitpid(child_pid)
        else
          environment  = ENV['RACK_ENV'] || 'development'
          default_host = environment == 'development' ? ::Toycol::Config::LOCALHOST : ::Config::DEFAULT_HOST

          host = options.delete(:Host) || default_host
          port = options.delete(:Port) || ::Toycol::Config::DEFAULT_PORT
          args = [host, port]

          ::Toycol::Proxy.new(host, port).start
        end
      end
    end

    register :toycol, Toycol
  end
end
