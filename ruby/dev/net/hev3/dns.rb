require "socket"

A_RDATA    = [127, 0, 0, 1].pack("C4")
AAAA_RDATA = ([0] * 15 + [1]).pack("C16")

HTTPS_RDATA = begin
  # <owner name>  IN [SVCB | HTTPS]  <SvcPriority>  <TargetName>  <SvcParams>
  priority   = [1].pack("n")     # <SvcPriority> 1
  target     = "\x00".b          # <TargetName>  "." (<owner name>とおなじ)

  alpn_value     = "\x02http/1.1".b             # alpn={h2,h3}
  alpn_param     = [1, alpn_value.bytesize].pack("nn") + alpn_value

  ipv4hint_value = [127, 0, 0, 1].pack("C4")    # ipv4hint=127.0.0.1
  ipv4hint_param = [4, ipv4hint_value.bytesize].pack("nn") + ipv4hint_value

  ipv6hint_value = ([0] * 15 + [1]).pack("C16") # ipv6hint=::1
  ipv6hint_param = [6, ipv6hint_value.bytesize].pack("nn") + ipv6hint_value

  priority + target + alpn_param + ipv4hint_param + ipv6hint_param
end

TYPE_MAP = {
  1 =>  { type: "A", data: A_RDATA },
  28 => { type: "AAAA", data: AAAA_RDATA },
  65 => { type: "HTTPS", data: HTTPS_RDATA },
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
    qtype = TYPE_MAP.dig(type, :type)
    qname = name.gsub(/[\x00-\x1f]/, ".").delete_prefix(".").delete_suffix(".")
    "#{qname} type=#{qtype}"
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

def respond(query)
  q = Query.new(query)
  puts "Received query: #{q.inspect}"

  # QR=1 / AA=1 / RCODE=0
  flags = "\x84\x00".b
  rdata = TYPE_MAP.dig(q.type, :data)

  # NAME / TYPE / CLASS / TTL / RDLENGTH / RDATA
  answer  = q.name + [q.type, 1, 300, rdata.bytesize].pack("nnNn") + rdata
  ancount = answer.empty? ? 0 : 1

  # ID / フラグ / QDCOUNT / ANCOUNT / NSCOUNT / ARCOUNT
  header = q.id + flags + [1, ancount, 0, 0].pack("nnnn")

  header + q.question + answer
end

sock = UDPSocket.new
sock.bind("127.0.0.1", 5300)
puts "DNS listining on 127.0.0.1:5300"

loop do
  data, addr = sock.recvfrom(512)
  _, port, _, ip_address, = addr

  begin
    response = respond(data)
    sock.send(response, 0, ip_address, port)
  rescue => e
    p e
  end
end
