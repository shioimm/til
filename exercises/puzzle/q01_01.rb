11.step(by: 2) do |n|
  next if n.to_s != n.to_s.reverse
  next if n.to_s(2) != n.to_s(2).reverse
  next if n.to_s(8) != n.to_s(8).reverse

  return p n
end
