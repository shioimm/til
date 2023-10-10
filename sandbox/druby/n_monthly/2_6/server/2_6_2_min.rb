# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト

require 'webrick'
require 'drb'
require 'irb'

IRB.setup(eval("__FILE__"), argv: [])
DRb.start_service('druby://:54345', IRB::WorkSpace.new())

$server = WEBrick::HTTPServer.new({ :Port => 8000 })

$server.mount_proc('/') do |req, res|
  res.content_type = 'text/html'
  res.body = <<EOS
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Probably</title>
</head>
<body>
<h1>It seems to work!</h1>
#{DRb.uri}
</body>
</html>
EOS
end

trap(:INT) { $server.shutdown }
$server.start

# $ docker build -t test/min .
# $ docker run --rm -it -p 8000:8000 test/min
