class Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env)
  end
end

App = run do |env|
  [200, {'content-type' => 'text/html'}, ['Hello']]
end

use Middleware
run App
