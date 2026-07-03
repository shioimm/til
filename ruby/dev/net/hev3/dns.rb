require "socket"

A_RDATA    = [127, 0, 0, 1].pack("C4")
AAAA_RDATA = ([0] * 15 + [1]).pack("C16")

HTTPS_RDATA = begin
  # <owner name>  IN [SVCB | HTTPS]  <SvcPriority>  <TargetName>  <SvcParams>
  priority   = [1].pack("n")     # <SvcPriority> 1
  target     = "\x00".b          # <TargetName>  "." (<owner name>とおなじ)
  alpn_value = "\x02h2\x02h3".b  # <SvcParams>   alpn={h2,h3}
  alpn_param = [1, alpn_value.bytesize].pack("nn") + alpn_value
  priority + target + alpn_param
end

TYPE_MAP = {
  1 =>  { name: "A", data: A_RDATA },
  28 => { name: "AAAA", data: AAAA_RDATA },
  65 => { name: "HTTPS", data: HTTPS_RDATA },
}

class Query
  def initialize(data)
    @data = data
  end

  def id = @data[0, 2]
  def name = @data[12, pos - 12]
  def type = @data[pos, 2].unpack1("n")
  def question = @data[12, pos - 12 + 4]

  def inspect
    qtype = TYPE_MAP.fetch(type, "TYPE#{type}")
    qname = name.gsub(/[\x00-\x1f]/, ".").delete_prefix(".").delete_suffix(".")
    "#{qtype[:name]} type=#{qname}"
  end

  private

  def pos
    return @pos if defined? @pos

    pos = 12 # Questionセクションの先頭ポジション
    pos += @data.getbyte(pos) + 1 while @data.getbyte(pos) != 0
    pos += 1
    @pos = pos
  end
end

def build_rr(name, type, rdata)
  # NAME / TYPE / CLASS / TTL / RDLENGTH /  RDATA
  name + [type, 1, 300, rdata.bytesize].pack("nnNn") + rdata
end

def respond(query)
  q = Query.new(query)
  puts "Received query: #{q.inspect}"

  flags   = "\x84\x00".b # QR=1 / AA=1 / RCODE=0
  answer  = build_rr(q.name, q.type, TYPE_MAP.dig(q.type, :data))
  ancount = answer.empty? ? 0 : 1
  header  = q.id + flags + [1, ancount, 0, 0].pack("nnnn")

  header + q.question + answer
end

sock = UDPSocket.new
sock.bind("127.0.0.1", 5300)
puts "DNS listining on 127.0.0.1:5300"

loop do
  data, addr = sock.recvfrom(512)
  port, _, ip_address, = addr

  begin
    response = respond(data)
    sock.send(response, 0, addr[3], addr[1])
  rescue => e
    p e
  end
end
