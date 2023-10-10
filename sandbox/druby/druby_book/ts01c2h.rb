# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'

def fact_client(ts, a, b, n = 100)
  req = []
  a.step(b, n) do |head|
    tail = [b, head + n - 1].min
    range = (head..tail)
    req.push(range)
    ts.write({"request" => "fact", "range" => range})
  end

  req.inject(1) do |value, range|
    tuple = ts.take({"answer" => "fact", "range" => range, "fact" => Integer})
    value * tuple["fact"]
  end
end

ts_uri = 'druby://localhost:12345'
DRb.start_service
$ts = DRbObject.new_with_uri(ts_uri)
p fact_client($ts, 1, 20000)
