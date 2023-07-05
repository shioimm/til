require 'resolv'
require 'socket'

hostname = "localhost"
port = 9292
resolver = Resolv::DNS.new
WORKING_THREADS = ThreadGroup.new

# NOTE:
#   DNS回答が複数レコードを含んでいる可能性があるため、
#   アドレスファミリごとにスレッドを生成するのは不可能な気がする

t1 = Thread.start(resolver) do |resolver|
  # 返り値が得られたらt2に通知する
  ipv6_addr = resolver.getresource(hostname, Resolv::DNS::Resource::IN::AAAA).address.to_s

  ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_addr)
  ipv6_addrinfo = Addrinfo.new(ipv6_sockaddr, Socket::AF_INET6, Socket::SOCK_STREAM, 0)

  # ConnectionAttemptDelay中?
  #   y -> ConnectionAttemptDelayを開始・後続処理
  #   n -> 解除を待機 -> 後続処理
  sock = ipv6_addrinfo.connect
  (WORKING_THREADS.list - [Thread.current]).each(&:kill)
  sock.write "GET / HTTP/1.0\r\n\r\n"
  print sock.read
  sock.close
end

WORKING_THREADS.add t1

t2 = Thread.start(resolver) do |resolver|
  # t1から通知受信済み?
  #   y -> 後続処理を実行
  #   n -> ResolutionDelay -> 後続処理を実行
  ipv4_addr = resolver.getresource(hostname, Resolv::DNS::Resource::IN::A).address.to_s

  ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_addr)
  ipv4_addrinfo = Addrinfo.new(ipv4_sockaddr, Socket::AF_INET, Socket::SOCK_STREAM, 0)


  # ConnectionAttemptDelay中?
  #   y -> ConnectionAttemptDelayを開始・後続処理
  #   n -> 解除を待機 -> 後続処理
  sock = ipv4_addrinfo.connect
  (WORKING_THREADS.list - [Thread.current]).each(&:kill)
  sock.write "GET / HTTP/1.0\r\n\r\n"
  print sock.read
  sock.close
end

WORKING_THREADS.add t2

WORKING_THREADS.list.each(&:join)
