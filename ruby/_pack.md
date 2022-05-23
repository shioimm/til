# Array#pack / String#unpack
- (Array#pack)    Rubyの文字列 / 数字 -> バイナリ
- (String#unpack) Rubyの文字列 / 数字 <- バイナリ

#### ビットストリング
```ruby
'abc'.encoding
=> #<Encoding:UTF-8>

'abc'.unpack1('B*')
=> "011000010110001001100011"

['011000010110001001100011'].pack('B*')
 => "abc" (#<Encoding:ASCII-8BIT>)
```

#### 8bit ASCII
```ruby
# 16進数表現
[0x00, 0x00, 0x00, 0x08, 0x57, 0x6f, 0x6f, 0x6f].pack("C*")
=> "\x00\x00\x00\bWooo" (#<Encoding:ASCII-8BIT>)

"\x00\x00\x00\bWooo".unpack("C*")
=> [0, 0, 0, 8, 87, 111, 111, 111] # 10進数表現

"\x00\x00\x00\bWooo".unpack("H*")
=> ["00000008576f6f6f"] # 16進数表現

# 10進数表現
[127, 0, 0, 1].pack("C*")
# => "\x7F\x00\x00\x01" (#<Encoding:ASCII-8BIT>)

"\x7F\x00\x00\x01".unpack('C*')
=> [127, 0, 0, 1]
```

#### ネットワークバイトオーダー
```ruby
# str.size = 3
[str.size].pack("N")
# => "\x00\x00\x00\x03"
```

## 参照
- [pack テンプレート文字列](https://docs.ruby-lang.org/ja/3.0/doc/pack_template.html)
- [Marshal フォーマット](https://docs.ruby-lang.org/ja/3.0/doc/marshal_format.html)
- [instance method String#unpack](https://docs.ruby-lang.org/ja/3.0.0/method/String/i/unpack.html)
- [instance method Array#pack](https://docs.ruby-lang.org/ja/3.0.0/method/Array/i/pack.html)
- [class Encoding](https://docs.ruby-lang.org/ja/3.0/class/Encoding.html)
