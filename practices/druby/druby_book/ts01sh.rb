# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'

class FactServer
  def initialize(ts)
    @ts = ts
  end

  def main_loop
    loop do
      tuple = @ts.take({"request" => "fact", "range" => Range})
      value = tuple["range"].inject(1) { |a, b| a * b }
      @ts.write({"answer" => "fact", "range" => tuple["range"], "fact" => value})
    end
  end
end

ts_uri = 'druby://localhost:12345'
DRb.start_service
$ts = DRbObject.new_with_uri(ts_uri)
FactServer.new($ts).main_loop
