# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト

# $ ruby ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/driq-0.4.3/lib/driq/webrick.rb

# $ irb -r drb --simple-prompt
# >> ro = DRbObject.new_with_uri "druby://localhost:54321"
# >> ro.keys
# => ["src", "webrick", "body"]
# >> it = ro['body']
# >> it['It Works'] = 'Does it work?'
# >> ro['body'] = it
# >> ro['src'].write "hello"
# >> ro['src'].write({:city => "Nasushiobara", :temp_low => -2.0 })
# >> ro['src'].write "<h1>hello</h1>"
# >> it = ro['body']
# >> it['innerHTML'] = 'textContent'
# >> ro['body'] = it
