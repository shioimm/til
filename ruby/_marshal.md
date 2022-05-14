# Marshal
- Rubyオブジェクトをファイルや文字列に書き出す

```ruby
class Foo
  def greeting
    'Hello'
  end
end
=> :greeting

m = Marshal.dump(Foo.new)
=> "\x04\bo:\bFoo\x00"

Marshal.load(m)
=> #<Foo:0x00007ff4ff196738>

Marshal.load(m, proc { |m| p m.greeting })
"Hello"
=> nil

m.unpack("x2 a a c a*")
=> ["o", ":", 8, "Foo\x00"]
```

#### Marshal.#dump (マーシャライズ) できないオブジェクト
- 無名Class / Moduleオブジェクト
- システム固有のデータを保持するオブジェクト (e.g. Dir, File::Stat, IO, File, Socket)
- MatchData, Data, Method, UnboundMethod, Proc, Thread, ThreadGroup, Continuation オブジェクト
- 特異メソッドを定義したオブジェクト

## 参照
- [module Marshal](https://docs.ruby-lang.org/ja/latest/class/Marshal.html)
- [Marshal フォーマット](https://docs.ruby-lang.org/ja/3.0/doc/marshal_format.html)
