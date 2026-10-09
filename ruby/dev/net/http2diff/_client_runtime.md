# client/runtime.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client/runtime.rb

```ruby
# frozen_string_literal: true
require 'thread'

module Net
  class HTTP
    class Client
      class Error < StandardError; end
      class ClosedError < Error; end
      class CancelledError < Error; end
      class PoolTimeout < Net::OpenTimeout; end
      class RequestTimeout < Timeout::Error; end
      class ProtocolError < Net::HTTPBadResponse; end
      class BodyTooLarge < Error; end
      class RedirectError < Error; end
      class ResponseError < Error
        attr_reader :response
        def initialize(response)
          @response = response
          super("HTTP #{response.code} #{response.message}")
        end
      end

      module Clock
        def self.now
          Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      end

      # A request owns its cancellation, including while it is connecting or waiting.
      class Operation
        attr_reader :deadline, :options

        # Client::Operation#initialize
        def initialize(options)
          @options = options
          @deadline = options[:timeout] && Clock.now + options[:timeout]
          @mutex = Mutex.new
          @cancelled = false
          @callback = nil
        end

        # Client::Operation#check!
        def check!
          raise CancelledError, 'request cancelled' if @cancelled
          raise RequestTimeout, 'request deadline exceeded' if @deadline && Clock.now >= @deadline
        end

        def remaining(limit = nil)
          check!
          left = @deadline && @deadline - Clock.now
          limit && left ? [limit, left].min : limit || left
        end

        def on_cancel(&callback)
          cancelled = @mutex.synchronize do
            @callback = callback
            @cancelled
          end
          callback.call if cancelled && callback
          check!
        end

        def detach
          @mutex.synchronize { @callback = nil }
        end

        def cancel
          @mutex.synchronize do
            return if @cancelled
            @cancelled = true
            @callback.call if @callback
          end
        rescue IOError, SystemCallError
          nil
        end
      end

      # No helper threads. Fiber Scheduler implementations can cooperate in sleep.
      # The uncontended pool and session paths never wait here.
      module Wait
        def self.pause(operation, deadline = nil)
          operation.check!
          if deadline && Clock.now >= deadline
            raise PoolTimeout, 'timed out waiting for a connection'
          end
          interval = operation.remaining(0.002)
          interval = [interval, deadline - Clock.now].min if deadline
          sleep([interval, 0].max)
        end
      end

      # The proxy leaves BufferedIO's parsing intact, but bounds every actual I/O wait
      # by the operation deadline. It is used only by modern H1 sessions.
      class TimedSocket
        attr_accessor :operation
        def raw_io; @io; end
        def initialize(io, operation)
          @io, @operation = io, operation
        end
        def inspect; "#<#{self.class}>"; end
        def to_io; self; end
        def closed?; @io.closed?; end
        def close; @io.close unless @io.closed?; end
        def eof?; @operation.check!; @io.eof?; end
        def wait_readable(timeout = nil)
          @io.to_io.wait_readable(@operation.remaining(timeout))
        end
        def wait_writable(timeout = nil)
          @io.to_io.wait_writable(@operation.remaining(timeout))
        end
        def read_nonblock(*args, **options)
          @operation.check!
          @io.read_nonblock(*args, **options)
        end
        def write_nonblock(*args, **options)
          @operation.check!
          @io.write_nonblock(*args, **options)
        end
        def <<(data)
          @io << data
        end
      end
      private_constant :Clock, :Operation, :Wait, :TimedSocket
    end
  end
end
```
