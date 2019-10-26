# Q07 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

require 'date'

TERM = Date.parse('19641010')..Date.parse('20200724')
dates = TERM.map { |date| date.strftime('%Y%m%d').to_i }
pp dates.select { |date| date.to_s(2).eql? date.to_s(2).reverse }
