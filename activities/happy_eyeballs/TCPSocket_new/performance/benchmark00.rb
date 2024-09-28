require 'socket'
require 'benchmark'

# remote host

hostname = "www.ruby-lang.org"
port = 80

n = 100

Benchmark.bmbm do |x|
  x.report("fast_fallback: true") do
    n.times { TCPSocket.new(hostname, port).close }
  end

  x.report("fast_fallback: false") do
    n.times { TCPSocket.new(hostname, port, fast_fallback: false).close }
  end
end

__END__

~/s/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb
Rehearsal --------------------------------------------------------
fast_fallback: true    0.017588   0.097045   0.114633 (  1.460664)
fast_fallback: false   0.014033   0.078984   0.093017 (  1.413951)
----------------------------------------------- total: 0.207650sec

                           user     system      total        real
fast_fallback: true    0.020891   0.124054   0.144945 (  1.473816)
fast_fallback: false   0.018392   0.110852   0.129244 (  1.466014)

__END__

# localhost

hostname = "localhost"
port = 9292

n = 1000

Benchmark.bmbm do |x|
  x.report("fast_fallback: true") do
    n.times { TCPSocket.new(hostname, port).close }
  end

  x.report("fast_fallback: false") do
    n.times { TCPSocket.new(hostname, port, fast_fallback: false).close }
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
