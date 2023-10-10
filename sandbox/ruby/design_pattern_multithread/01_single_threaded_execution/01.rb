# Java言語で学ぶデザインパターン入門 マルチスレッド編 第1章
# パーフェクトRuby 改訂2版 5-9

def countup
  File.open('01_counter', File::RDWR | File::CREAT) do |f|
    last_count = f.read.to_i
    f.rewind
    f.write last_count + 1
  end
end

10.times.map {
  Thread.fork {
    countup
  }
}.map(&:join)

puts File.read('01_counter').to_i
