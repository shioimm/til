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

## 起動

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

## call
```ruby
# core.rb

RT = self # shorthand reference
def call(env)
  info      = (env[ENV_INFO_KEY] ||= RequestDetails.new)
  info.id ||= env[HTTP_X_REQUEST_ID] || env[ACTION_DISPATCH_REQUEST_ID] || SecureRandom.uuid

  time_started_service = Time.now # リクエストがRackで処理され始めた実測時間
  ts_started_service   = fsecs    # リクエストがRackで処理され始めたmonotonic time
  time_started_wait    = RT._read_x_request_start(env) # Webサーバーがリクエストを最初に受信した時間

  # 追加の待ち時間が設定されていて、それが適用される場合
  effective_overtime   = (wait_overtime && RT._request_has_body?(env)) ? wait_overtime : 0
  seconds_service_left = nil

  # X-Request-Startが存在し、wait_timeoutが設定されている場合、
  # wait_timeoutよりも古いリクエストを失効させる（該当する場合は+wait_overtime）
  if time_started_wait && wait_timeout
    # Webサーバーが最初にリクエストを受信してからRackで処理できるようになるまでにかかった時間
    seconds_waited          = time_started_service - time_started_wait

    # ルーティングサーバーとアプリケーションサーバー間の潜在的な時間のずれを補う
    seconds_waited          = 0 if seconds_waited < 0

    # 許容できるリクエストの待ち時間
    final_wait_timeout      = wait_timeout + effective_overtime

    # WIP
    seconds_service_left    = final_wait_timeout - seconds_waited      # first calculation of service timeout (relevant if request doesn't get expired, may be overriden later)
    info.wait               = seconds_waited                           # updating the info properties; info.timeout will be the wait timeout at this point
    info.timeout            = final_wait_timeout

    if seconds_service_left <= 0 # expire requests that have waited for too long in the queue (as they are assumed to have been dropped by the web server / routing layer at this point)
      RT._set_state! env, :expired
      raise RequestExpiryError.new(env), "Request older than #{info.ms(:timeout)}."
    end
  end

  # pass request through if service_timeout is false (i.e., don't time it out at all.)
  return @app.call(env) unless service_timeout

  # compute actual timeout to be used for this request; if service_past_wait is true, this is just service_timeout. If false (the default), and wait time was determined, we'll use the shortest value between seconds_service_left and service_timeout. See comment above at service_past_wait for justification.
  info.timeout = service_timeout # nice and simple, when service_past_wait is true, not so much otherwise:
  info.timeout = seconds_service_left if !service_past_wait && seconds_service_left && seconds_service_left > 0 && seconds_service_left < service_timeout
  info.term    = term_on_timeout
  RT._set_state! env, :ready                            # we're good to go, but have done nothing yet

  heartbeat_event = nil                                 # init var so it's in scope for following proc
  register_state_change = ->(status = :active) {        # updates service time and state; will run every second
    heartbeat_event.cancel! if status != :active        # if the request is no longer active we should stop updating every second
    info.service = fsecs - ts_started_service           # update service time
    RT._set_state! env, status                          # update status
  }
  heartbeat_event = RT::Scheduler.run_every(1) { register_state_change.call :active }  # start updating every second while active; if log level is debug, this will log every sec

  timeout = RT::Scheduler::Timeout.new do |app_thread|  # creates a timeout instance responsible for timing out the request. the given block runs if timed out
    register_state_change.call :timed_out

    message = "Request "
    message << "waited #{info.ms(:wait)}, then " if info.wait
    message << "ran for longer than #{info.ms(:timeout)} "
    if term_on_timeout
      Thread.main['RACK_TIMEOUT_COUNT'] += 1

      if Thread.main['RACK_TIMEOUT_COUNT'] >= @term_on_timeout
        message << ", sending SIGTERM to process #{Process.pid}"
        Process.kill("SIGTERM", Process.pid)
      else
        message << ", #{Thread.main['RACK_TIMEOUT_COUNT']}/#{term_on_timeout} timeouts allowed before SIGTERM for process #{Process.pid}"
      end
    end

    app_thread.raise(RequestTimeoutException.new(env), message)
  end

  response = timeout.timeout(info.timeout) do           # perform request with timeout
    begin  @app.call(env)                               # boom, send request down the middleware chain
    rescue RequestTimeoutException => e                 # will actually hardly ever get to this point because frameworks tend to catch this. see README for more
      raise RequestTimeoutError.new(env), e.message, e.backtrace  # but in case it does get here, re-raise RequestTimeoutException as RequestTimeoutError
    ensure
      register_state_change.call :completed
    end
  end

  response
end
```
