# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'
require 'rinda/ring'

class Hello
  def greeting
    "Hello"
  end
end

hello = Hello.new
DRb.start_service(nil, hello)

provider = Rinda::RingProvider.new(:Hello, DRbObject.new(hello), 'Hello')
provider.provide

DRb.thread.join
