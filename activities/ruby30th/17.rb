reader, writer = IO.pipe
pid = fork do
  writer.puts "#ruby30th"
end
Process.waitpid(pid)
exec "echo", "-n", reader.gets
