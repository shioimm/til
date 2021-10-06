require 'rack'
require 'rack-timeout'
#require_relative 'rack_timeup'

class App
  def call(env)
    sleep 5
    [200, { 'Content-Type' => 'text/html' }, ["Hello\n"]]
  end
end

# use RackTimeup
use Rack::Timeout, service_timeout: 5
run App.new
