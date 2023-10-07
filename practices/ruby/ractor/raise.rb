pipe = Ractor.new do
  loop do
    Ractor.yield Ractor.receive
  end
end

[1, 2, 3].each do |i|
  Ractor.new(pipe, i) do |pipe, i|
    raise if i.even?

    pipe.send "#{i}: ok"
  rescue
    pipe.send "#{i}: ng"
  end
end

loop do
  begin
    p pipe.take
  end
end
