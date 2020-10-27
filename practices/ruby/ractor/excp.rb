r1 = Ractor.new { raise 'Raised' }

r2 = Ractor.new(r1) do |r1|
  begin
    r1.take
  rescue => e
    e.message
  end
end

p r2.take # => Raised (RuntimeError)
