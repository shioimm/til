require 'faraday'

response = Faraday.get('https://jsonplaceholder.typicode.com/posts/1')

puts "Status: #{response.status}"
puts
pp response.headers
puts
puts response.body

__END__
$ mkdir -p ~/.rbenv/versions/master
$ ln -s ~/src/install ~/.rbenv/versions/master # リンク元にインストール先 (bin/rubyがあるところ) を指定
$ rbenv local master
$ rbenv rehash
$ ruby -v
$ gem install bundler

(Gemfile)
source "https://rubygems.org"
gem "faraday"

$ bundle install
$ ruby faraday.rb
