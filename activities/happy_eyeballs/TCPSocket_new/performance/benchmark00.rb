require 'socket'
require 'benchmark'

HOSTNAME = "localhost"
PORT = 9292

n = 100
ai = Addrinfo.tcp(HOSTNAME, PORT)

Benchmark.bmbm do |x|
  x.report("Domain name") do
    n.times { TCPSocket.new(HOSTNAME, PORT).close }
  end

  x.report("IP Address") do
    n.times { TCPSocket.new(ai.ip_address, PORT).close }
  end
end

__END__

~/w/ruby ❯❯❯ ruby ../ruby/test.rb
Rehearsal -----------------------------------------------
Domain name   0.000485   0.002446   0.002931 (  0.005548)
IP Address    0.000231   0.001079   0.001310 (  0.002120)
-------------------------------------- total: 0.004241sec

                  user     system      total        real
Domain name   0.000326   0.001877   0.002203 (  0.004425)
IP Address    0.000180   0.000988   0.001168 (  0.002017)

~/w/ruby ❯❯❯ ../install/bin/ruby ../ruby/test.rb
Rehearsal -----------------------------------------------
Domain name   0.000610   0.003283   0.003893 (  0.004886)
IP Address    0.000253   0.001121   0.001374 (  0.002028)
-------------------------------------- total: 0.005267sec

                  user     system      total        real
Domain name   0.000523   0.002791   0.003314 (  0.004849)
IP Address    0.000212   0.001094   0.001306 (  0.001927)
