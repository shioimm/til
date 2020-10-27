# Ractor#send + Ractor.recv

r1 = Ractor.new { 'r1' }

r2 = Ractor.new { p Ractor.recv, 'r2' }
# Ractor.recvはsendの引数で渡されたオブジェクトを受け取る

# r1.takeの返り値はr1のブロックが返すオブジェクト('r1')
r2.send(r1.take) # 引数に直接オブジェクトを渡しても良い

r2.take # => 'r1''r2'
