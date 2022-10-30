begin
  i = 1
  eval "i++"
  p i
rescue SyntaxError => e
  puts "rescued"
end
