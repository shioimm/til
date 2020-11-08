# 引用: Rubyアプリケーションプログラミング P200

io_p  = IO.popen('ruby 5-2-3-cat.rb', 'r+')
count = 0

(0..10).each do
  STDERR.print('PUT: ', count, "\n")
  io_p.print(count, "\n")
  print('GET: ', io_p.gets)
  count += 1
  sleep 0.1
end
