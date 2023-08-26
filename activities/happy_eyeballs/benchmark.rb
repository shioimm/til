require 'benchmark'
require_relative 'socket'
# require_relative 'impl12'

Benchmark.bmbm do |x|
  x.report(:socket) do
    `ruby ~/til/activities/happy_eyeballs/socket.rb`
  end
end
