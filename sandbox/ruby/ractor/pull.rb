# Ractor.yield + Ractor#take

r1 = Ractor.new('r1') { |arg| Ractor.yield arg }
# Ractor.yieldはtakeされるまで処理を待つ

r2 = Ractor.new(r1) { |r1| puts r1.take, 'r2' }

r2.take # => 'r1''r2'
