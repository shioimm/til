require 'rubydns'

INTERFACES = [
  [:udp, "0.0.0.0", 5300],
  [:udp, "::1", 5300],
  [:tcp, "0.0.0.0", 5300],
  [:tcp, "::1", 5300],
]

IN = Resolv::DNS::Resource::IN

RubyDNS::run_server(INTERFACES) do
  match("www.ruby-lang.org", IN::A) do |transaction|
    puts "IN::A matched"
    transaction.respond!("127.0.0.1")
  end

  match("www.ruby-lang.org", IN::AAAA) do |transaction|
    puts "IN::AAAA matched"
    transaction.respond!("::1")
  end

  otherwise do |transaction|
    transaction.fail!(:NXDomain)
  end
end

__END__

$ dig @127.0.0.1 -p 5300 localhost
