reader, writer = IO.pipe
writer.puts '#ruby30th'
writer.close
puts reader.read
