# Q04 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

def cutbar(number_of_members, length_of_origin_bar, current_number_of_bars)
  if length_of_origin_bar < current_number_of_bars
    0
  elsif number_of_members > current_number_of_bars
    1 + cutbar(number_of_members, length_of_origin_bar, current_number_of_bars * 2)
  elsif number_of_members < current_number_of_bars
    1 + cutbar(number_of_members, length_of_origin_bar, current_number_of_bars + number_of_members)
  end
end

pp cutbar(3, 20, 1)
pp cutbar(5, 100, 1)
