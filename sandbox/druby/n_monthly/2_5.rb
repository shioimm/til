# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト

# $ docker run -it --rm rubylang/ruby irb -r drb --simple-prompt
# >> DRb.start_service('druby://:54345', {})
# >> DRb.front
# => {}
# >> DRb.uri
# => "druby://172.17.0.2:54345"

# $ docker run -it --rm rubylang/ruby irb -r drb --simple-prompt
# >> DRb.start_service
# >> DRb.uri
# => "druby://172.17.0.4:43547"
# >> kvs = DRbObject.new_with_uri "druby://172.17.0.2:54345"
# => #<DRb::DRbObject:0x0000564987494a68 @uri="druby://172.17.0.2:54345", @ref=nil>
# >> kvs['stdout'] = $stdout
# => #<IO:<STDOUT>>
