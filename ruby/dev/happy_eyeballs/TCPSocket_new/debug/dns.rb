require 'rubydns'

INTERFACES = [
  [:udp, "0.0.0.0", 53],
  [:udp, "::1",     53],
  [:tcp, "0.0.0.0", 53],
  [:tcp, "::1",     53],
]

IN = Resolv::DNS::Resource::IN

RubyDNS::run_server(INTERFACES) do
  match("www.ruby-lang.org", IN::A) do |transaction|
    puts "IN::A matched"
    transaction.respond!("127.0.0.1")
  end

  match("www.ruby-lang.org", IN::AAAA) do |transaction|
    # ここでsleepすると調整できる
    puts "IN::AAAA matched"
    transaction.respond!("::1")
  end

  otherwise do |transaction|
    transaction.fail!(:NXDomain)
  end
end

__END__

(Ubuntu環境で実行)
$ sudo apt update
$ sudo apt install build-essential ruby-dev libffi-dev libssl-dev
$ sudo gem install rubydns

(dns.rbを用意)
(/etc/resolf.conf)
# nameserver 127.0.0.53 # 一時的に無効化
nameserver 127.0.0.1
options edns0 trust-ad
search .

$ sudo ruby dns.rb
$ ruby server.rb # ポート番号4567

(動作確認)
$ dig @127.0.0.1 localhost
$ dig @127.0.0.1 localhost AAAA
$ ruby -rsocket -e "p TCPSocket.new('www.ruby-lang.org', 4567)"
# => #<TCPSocket:fd 7, AF_INET6, ::1, 44370>
