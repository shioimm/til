i = 0

def foo(&block)
  block.call %w[# r u b y 3 0 t h]
  foo(&block)
end

foo { |message| print message[i]; i += 1; break if i >= message.length }
puts "\n"
