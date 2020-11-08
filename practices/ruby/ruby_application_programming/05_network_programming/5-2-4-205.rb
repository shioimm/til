# 引用: Rubyアプリケーションプログラミング P205

require 'thread'

pr, pw = IO.pipe
cr, cw = IO.pipe

fork do
  pr.close
  pw.close
  STDIN.reopen cr
  STDIN.reopen cw
  exec('ruby 5-2-3-cat.rb')
end

cr.close
cw.close

thw = Thread.start do
  pw.sync = true
  count = 0

  (0..10).each do
    STDERR.print('PUT: ', count, "\n")
    pw.print(count, "\n")
    count += 1
    sleep 0.1
  end

  pw.close
end

thr = Thread.start do
  while s = pr.gets
    print("GET: ", s)
  end
end

thw.join
thr.join
