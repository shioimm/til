# 引用元: rubyネットワークプログラミング / 簡単なRSSクライアント
# http://www.geekpage.jp/programming/ruby-network/rss-0.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/library/rss.html

require 'rss'

# RSSクラスはRSSを扱う
rss = RSS::Parser.parse('http://b.hatena.ne.jp/hotentry?mode=rss')
# RSS::Parser.parseはRSS::RDFのインスタンスを返す

rss.items.each do |item|
  # RSS::RDF#itemsはRSS::RDF::Itemのインスタンスを要素として格納した配列を返す

  p item # => RSS::RDF::Itemのインスタンスを返す
  p item.title # => itemのタイトルを表示
end
