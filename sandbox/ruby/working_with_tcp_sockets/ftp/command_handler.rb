# 引用: Working with TCP Sockets P131

module FTP
  class CommandHandler
    CRLF = "\r\n"

    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def pwd
      @pwd || Dir.pwd
    end

    def handle(data)
      cmd     = data[0..3].strip.upcase
      options = data[4..-1].strip

      case cmd
      when 'USER'
        "230 Logged in anonymously"
      when 'SYST'
        "215 UNIX Working With FTP"
      when 'CWD'
        if File.directory?(options)
          @pwd = options
          "250 directory changed to #{pwd}"
        else
          "550 directory not found"
        end
      when 'PWD'
        "257 \"#{pwd}\" is the current directory"
      when 'PORT'
        ports      = options.split(',')
        ip_address = ports[0..3].join('.')
        port       = Integer(ports[4]) * 256 + Integer(ports[5])

        @data_socket = TCPSocket.new(ip_address, port)

        "200 Active connection established (#{port})"
      when 'RETR'
        file = File.open(File.join(pwd, options), 'r')
        connection.respond "125 Data transfer starting #{file.size} bytes"

        bytes = IO.copy_stream(file, @data_socket)
        @data_socket.close

        "226 Closing data connection, sent #{bytes} bytes"
      when 'LIST'
        connection.respond "125 Opening data connection for file list"

        result = Dir.entries(pwd).join(CRLF)
        @data_socket.write(result)
        @data_socket.close

        "226 Closing data connection, sent #{result.size} bytes"
      when 'QUIT'
        "221 Ciao"
      else
        "502 Don't know how to respond to #{cmd}"
      end
    end
  end
end
