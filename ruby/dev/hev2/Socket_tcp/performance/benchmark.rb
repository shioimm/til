require 'benchmark'

HOSTNAME = "localhost"
PORT = 9292

Benchmark.bmbm do |x|
  x.report("v5") do
    require_relative "../v5"
    100.times { Socket.tcp(HOSTNAME, PORT).close }
  end

  x.report("v6") do
    require_relative "../v6"
    100.times { Socket.tcp(HOSTNAME, PORT).close }
  end
end


__END__
require 'socket'
require 'benchmark'

HOSTNAME = "www.ruby-lang.org"
PORT = 80

ai = Addrinfo.tcp(HOSTNAME, PORT)

Benchmark.bmbm do |x|
  x.report("Domain name") do
    30.times { Socket.tcp(HOSTNAME, PORT).close }
  end

  x.report("IP Address") do
    30.times { Socket.tcp(ai.ip_address, PORT).close }
  end

  x.report("fast_fallback: false") do
    30.times { Socket.tcp(HOSTNAME, PORT, fast_fallback: false).close }
  end
end

# ~/s/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb
# Rehearsal --------------------------------------------------------
# Domain name            0.012003   0.021894   0.033897 (  0.418290)
# IP Address             0.006983   0.021459   0.028442 (  0.339960)
# fast_fallback: false   0.006970   0.027291   0.034261 (  0.463858)
# ----------------------------------------------- total: 0.096600sec
#
#                            user     system      total        real
# Domain name            0.014590   0.026427   0.041017 (  0.420891)
# IP Address             0.005251   0.016003   0.021254 (  1.371125)
# fast_fallback: false   0.007465   0.029140   0.036605 (  0.366034)
#
# ~/s/build ❯❯❯ ruby ../ruby/test.rb
# Rehearsal --------------------------------------------
# Ruby 3.3   0.004308   0.016682   0.020990 (  1.496522)
# ----------------------------------- total: 0.020990sec
#
#                user     system      total        real
# Ruby 3.3   0.007271   0.027410   0.034681 (  0.472510)

__END__

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
