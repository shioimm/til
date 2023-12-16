require 'socket'
require 'benchmark'

HOSTNAME = "localhost"
PORT = 9292
n = 10_000

Benchmark.bmbm do |x|
  x.report do
    n.times {
      Socket.tcp(HOSTNAME, PORT) do |socket|
        socket.write "Hi\r\n"
      end
    }
  end
end

# Original
# ~/w/build ❯❯❯ ruby ../ruby/test.rb
# Rehearsal ------------------------------------
#    0.168600   0.644748   0.813348 (  2.019796)
# --------------------------- total: 0.813348sec
#
#        user     system      total        real
#    0.162541   0.623680   0.786221 (  1.973641)

# HEv2
# ~/w/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb
# Rehearsal ------------------------------------
#    0.871444   2.409181   3.280625 (  3.339361)
# --------------------------- total: 3.280625sec
#
#        user     system      total        real
#    0.858527   2.411695   3.270222 (  3.370623)

require 'benchmark/ips'

Benchmark.ips do |x|
  x.report do
    n.times {
      Socket.tcp(HOSTNAME, PORT) do |socket|
        socket.write "hi\r\n"
      end
    }
  end
end

# Original
# ~/w/build ❯❯❯ ruby ../ruby/test.rb
# ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin22]
# Warming up --------------------------------------
#                          1.000 i/100ms
# Calculating -------------------------------------
#                           0.506 (± 0.0%) i/s -      3.000 in   5.929637s

# HEv2
# ~/w/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb
# ruby 3.3.0dev (2023-12-01T23:58:32Z Socket_tcp-hev2 9f6c6f88c3) [arm64-darwin22]
# Warming up --------------------------------------
#                          1.000 i/100ms
# Calculating -------------------------------------
#                           0.294 (± 0.0%) i/s -      2.000 in   6.792931s
