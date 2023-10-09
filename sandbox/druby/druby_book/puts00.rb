# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'

class Puts
  def initialize(stream = $stdout)
    @stream = stream
  end

  def puts(str)
    @stream.puts(str)
  end
end

uri = ARGV.shift
DRb.start_service(uri, Puts.new)
puts DRb.uri
sleep
