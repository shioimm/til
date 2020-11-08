# 引用: Rubyアプリケーションプログラミング P203

read, write = IO.pipe

pid = fork

if pid
  read.close
  count = 0
  loop do
    write.print(count, "\n")
    count += 1
    sleep 1
  end
else
  write.close
  while c = read.getc
    STDOUT.putc(c)
  end
end
