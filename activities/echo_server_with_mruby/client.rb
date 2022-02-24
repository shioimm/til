TCPSocket.open('localhost', 12345) do |conn|
  conn.puts ARGV[0].to_s
  conn.flush
  puts conn.gets
end
