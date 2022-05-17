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

### Marshalフォーマット
```
\x04\b 0                                  # ref.__drbref
\x04\b I \"   \r greeting \x06 : \x06 EF  # msg_id.id2name
\x04\b i \x06                             # arg.length
\x04\b I \"   \n dRuby    \x06 : \x06 ET  # args
\x04\b 0                                  # b

# \b - 語の区切り位置
#  0 - nil
#  I - インスタンス変数を持つObject, Class, Moduleのインスタンス以外
# \r - リターン
#  " - String
#  i - Fixnum
```

## 参照
- [module Marshal](https://docs.ruby-lang.org/ja/latest/class/Marshal.html)
- [Marshal フォーマット](https://docs.ruby-lang.org/ja/3.0/doc/marshal_format.html)
