# Q13 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

expression = "READ+WRITE+TALK==SKILL"
strings    = expression.scan(/\w+/)
chars      = strings.flat_map(&:chars).uniq
head       = strings.map{ |str| str[0] }

count = 0
(0..9).to_a.permutation(chars.size) do |seq|
  flag = false

  if seq.include?(0)
    flag = head.include?(chars[seq.index(0)])
  end

  if !flag
    e = expression.tr(chars.join, seq.join)
    if eval(e)
      p e
      count += 1
    end
  end
end

p count
