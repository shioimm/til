require "socket"
require "openssl"
require "http/2"

HOST = "example.com"
PORT = 443

tcp = TCPSocket.new(HOST, PORT)

ctx = OpenSSL::SSL::SSLContext.new
ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE # 証明書の検証を無効化
ctx.alpn_protocols = ["h2"]

tls = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
tls.sync_close = true # tls.close時にTCPもクローズする
tls.hostname = HOST
tls.connect

# サーバがh2を選択しなかった場合abort
if tls.alpn_protocol != "h2"
  abort("ALPN failed (negotiated: #{tls.alpn_protocol.inspect})")
end

conn = HTTP2::Client.new
stream = conn.new_stream # ストリームを作成
body = ""
finished = false

# フレームが生成されると呼ばれるコールバック
conn.on(:frame) do
  tls.write it # フレームの内容を表すバイト列
  tls.flush # 即時送信する
end

# レスポンスヘッダを受信すると呼ばれるコールバック
stream.on(:headers) do |headers|
  puts "--- HEADER ---"
  headers.each do |k, v|
    puts "#{k}: #{v}"
  end
end

# レスポンスボディチャンクを受信すると呼ばれるコールバック
stream.on(:data) do
  body << it # レスポンスボディのチャンクをbodyに追加
end

# このストリームがクローズすると呼ばれるコールバック
stream.on(:close) do
  finished = true
end

headers = {
  ":method"    => "GET",
  ":scheme"    => "https",
  ":authority" => "#{HOST}:#{PORT}",
  ":path"      => "/",
  "accept"     => "*/*",
}

# PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n + SETTINGS + HEADERSを送信
stream.headers(headers, end_stream: true) # end_stream: true = リクエストボディなし (GET)

begin
  until finished
    r, = IO.select([tls], nil, nil, nil) # 読み込み可能になるまで待機
    data = tls.readpartial(16 * 1024) # 受信したバイト列を取得
    conn << data # 取得したバイト列をHTTP/2パーサへ供給 -> イベントが発火
  end
rescue EOFError # サーバ側がクローズしたなどの場合
ensure
  puts "--- BODY ---"
  puts body
  tls.close
end
