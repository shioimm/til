# https://ui.perfetto.dev
# https://moyomot.hatenablog.com/entry/2014/05/04/232538

require "gvl-tracing"

count = 0
countable = true

GvlTracing.start("trace_gvl.json")

threads = 5.times.map do
  Thread.new do
    if countable
      count += 1
      countable = false
    end
  end
end

threads.each(&:join)

GvlTracing.stop
