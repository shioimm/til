# ruby/specを修正

```ruby
# spec/ruby/library/socket/socket/getnameinfo_spec.rb

describe 'Socket.getnameinfo' do
  describe 'using a String as the first argument' do
    before do
      @addr = Socket.sockaddr_in(21, '127.0.0.1')
    end

    it 'raises SocketError or TypeError when using an invalid String' do
      -> { Socket.getnameinfo('cats') }.should raise_error(Exception) { |e|
        (e.is_a?(SocketError) || e.is_a?(TypeError)).should == true # 修正
      }
    end

    # ...
  end
end
```
