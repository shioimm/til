# Q14 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

@countries = ["Algeria", "Argentina", "Australia",
              "Belgium", "Bosnia and Herzegovina", "Brazil",
              "Chile", "Colombia", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cameroon",
              "Ecuador", "England",
              "France",
              "Greece", "Germany", "Ghana",
              "Honduras",
              "Iran", "Italy",
              "Japan",
              "Korea Republic",
              "Mexico",
              "Netherlands", "Nigeria",
              "Portugal",
              "Russia",
              "Spain", "Switzerland",
              "Uruguay", "USA"]

def search(countries, prev, depth)
  flag = true

  next_countries = countries.select { |country| country[0].eql? prev[-1].upcase }

  if !next_countries.empty?
    next_countries.each do |next_country|
      search(countries - [next_country], next_country, depth + 1)
    end
  else
    @maximum_depth = [@maximum_depth, depth].max
  end
end

@maximum_depth = 0

@countries.each do |country|
  search(@countries - [country], country, 1)
end

puts @maximum_depth
