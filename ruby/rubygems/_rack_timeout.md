# rack-timeout
- [sharpstone/rack-timeout](https://github.com/sharpstone/rack-timeout)

```
├── rack
│   └── timeout
│       ├── base.rb  # Rack::Timeout::Logger.initを実行
│       ├── core.rb
│       ├── logger.rb
│       ├── logging-observer.rb
│       ├── rails.rb
│       ├── rollbar.rb
│       └── support
│           ├── monotonic_time.rb
│           ├── namespace.rb
│           ├── scheduler.rb
│           └── timeout.rb
└── rack-timeout.rb
```

```ruby
# logger.rb

def init
  @observer = ::Rack::Timeout::StateChangeLoggingObserver.new
  ::Rack::Timeout.register_state_change_observer(:logger, &@observer.callback)
  @inited = true
end
```

```ruby
# logging-observer.rb

class Rack::Timeout::StateChangeLoggingObserver
  def initialize
    @logger = nil
  end
  # ...
  # returns the Proc to be used as the observer callback block
  def callback
    method(:log_state_change)
  end
  # ...
  # generates the actual log string
  def log_state_change(env)
    info = env[::Rack::Timeout::ENV_INFO_KEY]
    level = STATE_LOG_LEVEL[info.state]
    logger(env).send(level) do
      s  = "source=rack-timeout"
      s << " id="      << info.id           if info.id
      s << " wait="    << info.ms(:wait)    if info.wait
      s << " timeout=" << info.ms(:timeout) if info.timeout
      s << " service=" << info.ms(:service) if info.service
      s << " term_on_timeout=" << info.term.to_s if info.term
      s << " state="   << info.state.to_s   if info.state
      s
    end
  end
end
```

```ruby
# logger.rb

module Rack
  class Timeout
    def self.register_state_change_observer(id, &callback)
      # ...
      @state_change_observers[id] = callback
    end
```
