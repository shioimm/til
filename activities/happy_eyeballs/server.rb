require 'socket'

class Server
  class VersionError < StandardError; end

  PORT = 9292

  def initialize(version, address)
    @version = version
    @socket = Socket.new(domain, :STREAM)
    address = Socket.pack_sockaddr_in(PORT, address)
    @socket.bind(address)
  end

  def accept_loop
    puts "#{version} server started"
    # コネクションを確立できないサーバー
    #sleep

    @socket.listen(5)

    loop do
      trap(:INT) { shutdown }
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

  def shutdown
    @socket.close
    exit
  end
end

if child_pid = fork
  Server.new(:ipv4, '127.0.0.1').accept_loop
  Process.waitpid(child_pid)
else
  Server.new(:ipv6, '::1').accept_loop
end
