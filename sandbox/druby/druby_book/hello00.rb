# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'

uri = ARGV.shift
there = DRbObject.new_with_uri(uri)
there.puts 'Hello'
