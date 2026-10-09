## client.rb
https://github.com/nurse/net-http/blob/8ac46b06f4c63388d03c59a1f05c036a9e8a99b3/lib/net/http/client/pool.rb

```ruby
# frozen_string_literal: true
module Net
  class HTTP
    class Client
      # The process pool knows only reservation/release, close, idle state and route.
      # Protocol sessions own stream credit and the meaning of a reservation.
      class Pool
        # Client::Pool::Entry
        Entry = Struct.new(:key, :session, :used_at, :origin)

        def initialize(max_connections: 100, max_connections_per_origin: 10, idle_timeout: 30)
          @limit, @origin_limit, @idle_timeout = max_connections, max_connections_per_origin, idle_timeout
          @pid = Process.pid
          @mutex = Mutex.new
          @entries, @connecting, @connecting_origins = [], {}, {}
          @closed = false
          @next_reap = 0
        end

        # Client::Pool#acquire
        def acquire(key, operation, origin: key)
          reset_after_fork
          deadline = nil

          loop do
            operation.check!
            create = false
            lease = @mutex.synchronize do
              raise ClosedError, 'connection pool shut down' if @closed
              reap
              found = nil
              @entries.each do |entry|
                next unless entry.key == key
                reservation = entry.session.reserve
                if reservation
                  found = [entry, reservation]
                  break
                end
              end

              unless found
                origin_count = @entries.count { |e| e.origin == origin } + @connecting_origins.fetch(origin, 0)
                if origin_count >= @origin_limit
                  idle = @entries.select { |e| e.origin == origin && e.session.idle? && e.key != key }.min_by(&:used_at)
                  if idle
                    @entries.delete(idle)
                    idle.session.close
                    origin_count -= 1
                  end
                end

                if origin_count < @origin_limit && @connecting.fetch(key, 0).zero?
                  if @entries.size + @connecting.values.inject(0, :+) >= @limit
                    idle = @entries.select { |e| e.session.idle? }.min_by(&:used_at)
                    if idle
                      @entries.delete(idle)
                      idle.session.close
                    end
                  end
                  if @entries.size + @connecting.values.inject(0, :+) < @limit
                    @connecting[key] = @connecting.fetch(key, 0) + 1
                    @connecting_origins[origin] = @connecting_origins.fetch(origin, 0) + 1
                    create = true
                  end
                end
              end
              found
            end

            return lease if lease

            if create
              session = nil
              registered = false
              begin
                session = yield
                operation.check!
                lease = @mutex.synchronize do
                  raise ClosedError, 'connection pool shut down' if @closed

                  entry = Entry.new(key, session, Clock.now, origin)

                  @entries << entry
                  registered = true
                  reservation = session.reserve
                  reservation && [entry, reservation]
                end
                return lease if lease
              ensure
                @mutex.synchronize do
                  count = @connecting.fetch(key, 1) - 1
                  count.zero? ? @connecting.delete(key) : @connecting[key] = count
                  origin_count = @connecting_origins.fetch(origin, 1) - 1
                  origin_count.zero? ? @connecting_origins.delete(origin) : @connecting_origins[origin] = origin_count
                end
                session.close if session && !registered
              end
            end

            deadline ||= Clock.now + operation.remaining(operation.options[:pool_timeout])
            sessions = @mutex.synchronize { @entries.select { |e| e.key == key }.map(&:session) }
            begin
              sessions.each { |session| session.progress(operation) if session.respond_to?(:progress) }
            rescue StandardError
              @mutex.synchronize { @entries.delete_if { |entry| entry.session.closed? } }
              raise
            end
            Wait.pause(operation, deadline)
          end
        end

        def release(entry, reservation)
          entry.session.release(reservation)
          @mutex.synchronize do
            entry.used_at = Clock.now
            if @closed || entry.session.closed?
              @entries.delete(entry)
              entry.session.close
            end
          end
        end

        def shutdown
          reset_after_fork
          sessions = @mutex.synchronize do
            @closed = true
            @entries.map(&:session).tap { @entries.clear }
          end
          sessions.each(&:close)
        end

        def stats
          reset_after_fork
          @mutex.synchronize do
            {connections: @entries.size, connecting: @connecting.values.inject(0, :+),
             active: @entries.count { |e| !e.session.idle? }}.freeze
          end
        end

        private

        def reap
          now = Clock.now
          return if now < @next_reap
          @next_reap = now + @idle_timeout
          @entries.delete_if do |entry|
            expired = entry.session.closed? || (entry.session.idle? && now - entry.used_at >= @idle_timeout)
            entry.session.close if expired
            expired
          end
          nearest = @entries.select { |entry| entry.session.idle? }.map { |entry| entry.used_at + @idle_timeout }.min
          @next_reap = nearest || now + @idle_timeout
        end

        def reset_after_fork
          return if @pid == Process.pid
          # No inherited mutex may be acquired in a forked child.
          @entries.each { |entry| entry.session.discard_after_fork }
          @entries, @connecting, @connecting_origins = [], {}, {}
          @mutex = Mutex.new
          @closed = false
          @next_reap = 0
          @pid = Process.pid
        end
      end
      private_constant :Pool
    end
  end
end
```
