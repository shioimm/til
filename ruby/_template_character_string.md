# 文字列変換
## 文字列 <-> 二進数
```ruby
# 文字列を二進数に変換する
'abc'.unpack1('B*') # => "011000010110001001100011"

# 二進数を文字列に変換する
['011000010110001001100011'].pack('B*') # => "abc"
```

## 文字列 -> 8bit 符号なし整数
```ruby
[0x00, 0x00, 0x00, 0x08, 0x57, 0x6f, 0x6f, 0x6f].pack("C*") # => \x00\x00\x00\bWooo
```

## 参照
- [instance method String#unpack](https://docs.ruby-lang.org/ja/3.0.0/method/String/i/unpack.html)
- [instance method Array#pack](https://docs.ruby-lang.org/ja/3.0.0/method/Array/i/pack.html)
