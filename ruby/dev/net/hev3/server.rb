require "puma"
require "puma/configuration"

app = Proc.new { |env|
  [200, { "content-type" => "text/plain" }, ["Hello!\n"]]
}

server = Puma::Server.new(app)

config = Puma::Configuration.new do |conf|
  conf.port     8080, "localhost"

  # $ openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=localhost"
  conf.ssl_bind "localhost", 8443, { cert: ARGV[0], key: ARGV[1] }

  conf.app app
end

Puma::Launcher.new(config).run
