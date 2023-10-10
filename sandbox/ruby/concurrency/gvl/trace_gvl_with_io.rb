# https://ui.perfetto.dev
# https://moyomot.hatenablog.com/entry/2014/05/04/232538

require "gvl-tracing"

count = 0
countable = true

GvlTracing.start("trace_gvl_with_io.json")

threads = 5.times.map do
  Thread.new do
    if countable
      puts "not thread safe" # <- ここを実行する際にGVLが解放されて
      count += 1 # <- 新たに別スレッドがここに到達する
      countable = false  # <- ここまで到達する場合もある
    end
  end
end

threads.each(&:join)

GvlTracing.stop
