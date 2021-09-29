require 'timeout'

class RackTimeup
  def initialize(app)
    @app = app
  end

  def call(env)
    Timeout.timeout(10) {
      @app.call(env)
    }
  end
end
