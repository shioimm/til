require 'stackprof'
require 'socket'

HOSTNAME = "localhost"
PORT = 9292

profile = StackProf.run(mode: :cpu, interval: 1000) do
  10_000.times do
    Socket.tcp(HOSTNAME, PORT) do |socket|
      socket.write "Hi\r\n"
    end
  end
end

result = StackProf::Report.new(profile)
puts
result.print_text

# Original
# ~/w/build ❯❯❯ ruby ../ruby/test.rb
#
# ==================================
#   Mode: wall(1000)
#   Samples: 1994 (0.25% miss rate)
#   GC: 3 (0.15%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#       1494  (74.9%)        1494  (74.9%)     Addrinfo.getaddrinfo
#        347  (17.4%)         347  (17.4%)     Socket#connect
#         74   (3.7%)          74   (3.7%)     Socket#initialize
#         46   (2.3%)          46   (2.3%)     IO#write
#         16   (0.8%)          16   (0.8%)     IO#close
#          4   (0.2%)           4   (0.2%)     BasicSocket#setsockopt
#          3   (0.2%)           3   (0.2%)     (sweeping)
#        430  (21.6%)           3   (0.2%)     Addrinfo#connect_internal
#       1926  (96.6%)           2   (0.1%)     Addrinfo.foreach
#          1   (0.1%)           1   (0.1%)     Addrinfo#pfamily
#       1990  (99.8%)           1   (0.1%)     Socket.tcp
#       1991  (99.8%)           1   (0.1%)     block (2 levels) in <main>
#         47   (2.4%)           1   (0.1%)     block (3 levels) in <main>
#          5   (0.3%)           1   (0.1%)     Socket#ipv6only!
#          3   (0.2%)           0   (0.0%)     (garbage collection)
#         74   (3.7%)           0   (0.0%)     IO.new
#       1991  (99.8%)           0   (0.0%)     <main>
#       1991  (99.8%)           0   (0.0%)     StackProf.run
#       1991  (99.8%)           0   (0.0%)     Integer#times
#       1991  (99.8%)           0   (0.0%)     block in <main>
#        430  (21.6%)           0   (0.0%)     Array#each
#        430  (21.6%)           0   (0.0%)     Addrinfo#connect
#
# ~/w/build ❯❯❯ ruby ../ruby/test.rb
#
# ==================================
#   Mode: cpu(1000)
#   Samples: 703 (0.00% miss rate)
#   GC: 3 (0.43%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#        433  (61.6%)         433  (61.6%)     Addrinfo.getaddrinfo
#        123  (17.5%)         123  (17.5%)     Socket#connect
#         81  (11.5%)          81  (11.5%)     Socket#initialize
#         37   (5.3%)          37   (5.3%)     IO#write
#         16   (2.3%)          16   (2.3%)     IO#close
#          9   (1.3%)           9   (1.3%)     BasicSocket#setsockopt
#          3   (0.4%)           3   (0.4%)     (sweeping)
#        647  (92.0%)           1   (0.1%)     Addrinfo.foreach
#        213  (30.3%)           0   (0.0%)     Addrinfo#connect_internal
#        213  (30.3%)           0   (0.0%)     Addrinfo#connect
#        213  (30.3%)           0   (0.0%)     Array#each
#         37   (5.3%)           0   (0.0%)     block (3 levels) in <main>
#          9   (1.3%)           0   (0.0%)     Socket#ipv6only!
#          3   (0.4%)           0   (0.0%)     (garbage collection)
#        700  (99.6%)           0   (0.0%)     Socket.tcp
#        700  (99.6%)           0   (0.0%)     block (2 levels) in <main>
#        700  (99.6%)           0   (0.0%)     Integer#times
#        700  (99.6%)           0   (0.0%)     block in <main>
#        700  (99.6%)           0   (0.0%)     StackProf.run
#        700  (99.6%)           0   (0.0%)     <main>
#         81  (11.5%)           0   (0.0%)     IO.new

# -----------------------------------------------------------------------------------------------------------

# HEv2
# ~/w/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb
# Ignoring racc-1.7.1 because its extensions are not built. Try: gem pristine racc --version 1.7.1
# Ignoring rbs-3.2.2 because its extensions are not built. Try: gem pristine rbs --version 3.2.2
# Ignoring ruby-prof-1.6.2 because its extensions are not built. Try: gem pristine ruby-prof --version 1.6.2
#
# ==================================
#   Mode: wall(1000)
#   Samples: 3318 (0.00% miss rate)
#   GC: 141 (4.25%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#       2222  (67.0%)        2222  (67.0%)     IO.select
#        327   (9.9%)         324   (9.8%)     Socket#__connect_nonblock
#        172   (5.2%)         172   (5.2%)     Thread#initialize
#        123   (3.7%)         123   (3.7%)     (sweeping)
#        110   (3.3%)         110   (3.3%)     Socket#initialize
#         60   (1.8%)          60   (1.8%)     IO#close
#         58   (1.7%)          58   (1.7%)     IO#write
#         46   (1.4%)          46   (1.4%)     IO#getbyte
#         84   (2.5%)          35   (1.1%)     Thread::Mutex#synchronize
#         50   (1.5%)          32   (1.0%)     IO.pipe
#       3174  (95.7%)          28   (0.8%)     Socket.tcp
#         18   (0.5%)          18   (0.5%)     IO#initialize
#         16   (0.5%)          16   (0.5%)     (marking)
#        180   (5.4%)           8   (0.2%)     Thread.new
#          7   (0.2%)           7   (0.2%)     Process.clock_gettime
#          4   (0.1%)           4   (0.1%)     Hash#keys
#        114   (3.4%)           4   (0.1%)     IO.new
#         11   (0.3%)           4   (0.1%)     Socket.current_clocktime
#          4   (0.1%)           4   (0.1%)     Kernel#hash
#        113   (3.4%)           4   (0.1%)     Socket::HostnameResolutionQueue#get
#          3   (0.1%)           3   (0.1%)     Kernel#is_a?
#          3   (0.1%)           3   (0.1%)     SystemCallError#initialize
#          3   (0.1%)           3   (0.1%)     Socket::SelectableAddrinfos#add
#         55   (1.7%)           3   (0.1%)     Class#new
#         60   (1.8%)           2   (0.1%)     block (3 levels) in <main>
#          2   (0.1%)           2   (0.1%)     Array#concat
#          2   (0.1%)           2   (0.1%)     Thread::Queue#empty?
#        141   (4.2%)           2   (0.1%)     (garbage collection)
#       3020  (91.0%)           2   (0.1%)     Kernel#loop
#        192   (5.8%)           2   (0.1%)     Array#map
#          3   (0.1%)           2   (0.1%)     Socket::ConnectingSockets#add
#       3177  (95.8%)           2   (0.1%)     Integer#times
#          3   (0.1%)           2   (0.1%)     Socket::SelectableAddrinfos#get
#          1   (0.0%)           1   (0.0%)     Thread::Queue#initialize
#       3175  (95.7%)           1   (0.0%)     block (2 levels) in <main>
#          1   (0.0%)           1   (0.0%)     Addrinfo#protocol
#          1   (0.0%)           1   (0.0%)     Enumerable#all?
#          8   (0.2%)           1   (0.0%)     Socket.second_to_timeout
#          2   (0.1%)           1   (0.0%)     Array#each
#          1   (0.0%)           1   (0.0%)     SystemCallError.===
#        328   (9.9%)           1   (0.0%)     Socket#connect_nonblock
#         53   (1.6%)           1   (0.0%)     Socket::HostnameResolutionQueue#initialize
#       3177  (95.8%)           0   (0.0%)     block in <main>
#       3177  (95.8%)           0   (0.0%)     StackProf.run
#          1   (0.0%)           0   (0.0%)     Socket::SelectableAddrinfos#empty?
#       3177  (95.8%)           0   (0.0%)     <main>
#          3   (0.1%)           0   (0.0%)     Hash#delete
#        203   (6.1%)           0   (0.0%)     Socket::ConnectingSockets#nonblocking_connect
#          1   (0.0%)           0   (0.0%)     Socket::ConnectingSockets#each
#          3   (0.1%)           0   (0.0%)     Socket::ConnectingSockets#all
#
# ~/w/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb
# Ignoring racc-1.7.1 because its extensions are not built. Try: gem pristine racc --version 1.7.1
# Ignoring rbs-3.2.2 because its extensions are not built. Try: gem pristine rbs --version 3.2.2
# Ignoring ruby-prof-1.6.2 because its extensions are not built. Try: gem pristine ruby-prof --version 1.6.2
#
# ==================================
#   Mode: cpu(1000)
#   Samples: 2108 (26.19% miss rate)
#   GC: 170 (8.06%)
# ==================================
#      TOTAL    (pct)     SAMPLES    (pct)     FRAME
#        485  (23.0%)         485  (23.0%)     Addrinfo.getaddrinfo
#        346  (16.4%)         346  (16.4%)     IO.select
#        261  (12.4%)         257  (12.2%)     Socket#__connect_nonblock
#        168   (8.0%)         168   (8.0%)     IO#write
#        156   (7.4%)         156   (7.4%)     Thread#initialize
#        145   (6.9%)         145   (6.9%)     Socket#initialize
#        126   (6.0%)         126   (6.0%)     (sweeping)
#         74   (3.5%)          74   (3.5%)     IO#close
#         59   (2.8%)          59   (2.8%)     IO#getbyte
#        193   (9.2%)          52   (2.5%)     Thread::Mutex#synchronize
#         60   (2.8%)          44   (2.1%)     IO.pipe
#        170   (8.1%)          24   (1.1%)     (garbage collection)
#         20   (0.9%)          20   (0.9%)     (marking)
#         16   (0.8%)          16   (0.8%)     IO#initialize
#       1823  (86.5%)           7   (0.3%)     Socket.tcp
#          4   (0.2%)           4   (0.2%)     SystemCallError#initialize
#          3   (0.1%)           3   (0.1%)     Process.clock_gettime
#          3   (0.1%)           3   (0.1%)     Socket::SelectableAddrinfos#get
#        128   (6.1%)           2   (0.1%)     Socket::HostnameResolutionQueue#get
#        146   (6.9%)           1   (0.0%)     IO.new
#        262  (12.4%)           1   (0.0%)     Socket#connect_nonblock
#          1   (0.0%)           0   (0.0%)     Socket.second_to_timeout
#          3   (0.1%)           0   (0.0%)     Socket.current_clocktime
#          2   (0.1%)           0   (0.0%)     Array#each
#         60   (2.8%)           0   (0.0%)     Class#new
#         60   (2.8%)           0   (0.0%)     Socket::HostnameResolutionQueue#initialize
#       1051  (49.9%)           0   (0.0%)     Kernel#loop
#        150   (7.1%)           0   (0.0%)     Socket::ConnectingSockets#nonblocking_connect
#         87   (4.1%)           0   (0.0%)     block (3 levels) in <main>
#       1230  (58.3%)           0   (0.0%)     block (2 levels) in <main>
#        156   (7.4%)           0   (0.0%)     Array#map
#        156   (7.4%)           0   (0.0%)     Thread.new
#       1230  (58.3%)           0   (0.0%)     Integer#times
#       1230  (58.3%)           0   (0.0%)     block in <main>
#       1230  (58.3%)           0   (0.0%)     StackProf.run
#       1230  (58.3%)           0   (0.0%)     <main>
#        593  (28.1%)           0   (0.0%)     Socket.hostname_resolution
#        108   (5.1%)           0   (0.0%)     Socket::HostnameResolutionQueue#add_resolved
#         81   (3.8%)           0   (0.0%)     IO#putc
