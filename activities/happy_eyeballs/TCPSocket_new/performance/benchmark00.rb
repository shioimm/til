require 'socket'
require 'benchmark'

HOSTNAME = "localhost"
PORT = 9292

n = 1000

Benchmark.bmbm do |x|
  x.report("fast_fallback: true") do
    n.times { TCPSocket.new(HOSTNAME, PORT).close }
  end

  x.report("fast_fallback: false") do
    n.times { TCPSocket.new(HOSTNAME, PORT, fast_fallback: false).close }
  end
end

__END__

~/w/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb
Rehearsal --------------------------------------------------------
fast_fallback: true    0.027206   0.141390   0.168596 (  0.279012)
fast_fallback: false   0.018718   0.094518   0.113236 (  0.237073)
----------------------------------------------- total: 0.281832sec

                           user     system      total        real
fast_fallback: true    0.028090   0.147802   0.175892 (  0.249219)
fast_fallback: false   0.018436   0.096178   0.114614 (  0.246049)
