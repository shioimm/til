# 引用: Rubyアプリケーションプログラミング P200

r, w = IO.pipe

trap("CHLD") do
  print "Child status = #{Process.wait2.inspect}\n"
end

pid = fork

if pid
  r.close
  count = 0

  loop do
    w.print(count, "\n")
    count += 1
    sleep 1
  end
else
  trap("CHLD", "DEFAULT")
  w.close

  while c = r.getc
    STDOUT.putc(c)
  end
end
