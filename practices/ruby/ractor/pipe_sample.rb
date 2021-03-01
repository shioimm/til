pipe = Ractor.new do
  loop do
    n = Ractor.receive
    Ractor.yield n + 1
  end
end

Ractor.new(pipe, n = 0) do |pipe, n|
  loop do
    pipe.send n
    next_n = pipe.take
    n = next_n
  end
end.take
