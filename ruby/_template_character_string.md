# 文字列変換
#### 二進数
```ruby
'abc'.unpack1('B*')
# => "011000010110001001100011" (#<Encoding:US-ASCII>)

['011000010110001001100011'].pack('B*')
# => "abc" (#<Encoding:ASCII-8BIT>)
```

#### 8bit ASCII
```ruby
[0x00, 0x00, 0x00, 0x08, 0x57, 0x6f, 0x6f, 0x6f].pack("C*")
# => "\x00\x00\x00\bWooo" (#<Encoding:ASCII-8BIT>)

[127, 0, 0, 1].pack("C*")
# => "\x7F\x00\x00\x01" (#<Encoding:ASCII-8BIT>)
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
