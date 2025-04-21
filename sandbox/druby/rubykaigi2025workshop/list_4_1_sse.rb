require "webrick"
require "driq"
require "driq/webrick"
require "drb"

src = Driq::EventSource.new
svr = WEBrick::HTTPServer.new(:Port => 8086)
body = <<EOS
<!DOCTYPE html>
<html>
  <head>
    <title>SSE</title>
  </head>
  <body>
    <h1>It Works!</h1>
    <ul id="list">
    </ul>
  </body>

  <script>
  var evt = new EventSource("/stream")
  evt.onmessage = function(e) {
    var newElement = document.createElement("li")
    var eventList = document.getElementById("list")
    newElement.innerHTML = "message: " + e.data
    eventList.appendChild(newElement)
  }
  </script>
</html>
EOS

front = { "src" => src, "webrick" => svr, "body" => body }
DRb.start_service("druby://localhost:54320", front)

svr.mount_proc "/" do |req, res|
  res.body = front["body"]
end

svr.mount_proc("/stream") { |req, res|
  last_event_id = req["Last-Event-Id"]
  res.content_type = "text/event-stream"
  res.chunked = true
  res.body = WEBrick::ChunkedStream.new(Driq::EventStream.new(src, last_event_id))
}

svr.start
