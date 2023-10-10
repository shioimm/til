require 'async'

# 操作が完了するまでの間GVLが解放される処理をブロックする
Async do # イベントループの作成
  10.times do
    Async do
      File.open('fiber_counter', File::RDWR | File::CREAT) do |f|
        ex_count = f.read.to_i
        count = ex_count + 1
        f.rewind
        f.write count
      end
    end
  end
end

puts File.read('fiber_counter').to_i
