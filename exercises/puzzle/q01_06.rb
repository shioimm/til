# Q06 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

def loop?(n)
  checksum = n * 3 + 1

  while checksum != 1
    checksum = checksum.odd? ? checksum * 3 + 1 : checksum / 2
    return true if checksum.eql? n
  end

  false
end

pp 2.step(by: 2, to: 10000).count { |n| loop? n }
