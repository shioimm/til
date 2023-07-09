require 'socket'

class Server
  class VersionError < StandardError; end

  PORT = 9292

  def initialize(version, wait: 0)
    @version = version
    @wait = wait
    @socket = Socket.new(domain, :STREAM)
    sockaddr = Socket.pack_sockaddr_in(PORT, address)
    @socket.setsockopt(:SOCKET, :REUSEADDR, true)
    @socket.bind(sockaddr)

    trap(:INT) { shutdown }
  end

  def accept_loop
    puts "#{version} server started"

    # 接続確立にかかる時間
    sleep(@wait)

    @socket.listen(5)

    loop do
      connection, client_addr = @socket.accept
      puts "#{version} received: #{connection.readpartial(128).gsub(/[\r\n]/,"")} from #{client_addr.ip_address}"
      connection.write("#{version}: ok\n")
      connection.close
    end
  end

  private

  def version
    @version.capitalize
  end

  def domain
    case @version
    when :ipv6 then :INET6
    when :ipv4 then :INET
    else
      raise VersionError
    end
  end

  def address
    case @version
    when :ipv6 then '::1'
    when :ipv4 then '127.0.0.1'
    else
      raise VersionError
    end
  end

  def shutdown
    @socket.close
    exit
  end
end

if child_pid = fork
  #Server.new(:ipv4, wait: 60 * 60 * 24).accept_loop
  Server.new(:ipv4, wait: 0).accept_loop
  Process.waitpid(child_pid)
else
  Server.new(:ipv6, wait: 60 * 60 * 24).accept_loop
  #Server.new(:ipv6, wait: 0).accept_loop
end
