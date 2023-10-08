def ractor
  r = Ractor.new 'ok' do |msg|
    msg
  end

  r.take
end

Thread.start { p ractor }.join
