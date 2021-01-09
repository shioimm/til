r = Ractor.new {
  loop do
    Ractor.yield Ractor.recv
    sleep 1
  end
}

10.times do
  now = Time.now.strftime('%Y/%m/%d %H:%M:%S')

  r.send now

  p r.take
end
