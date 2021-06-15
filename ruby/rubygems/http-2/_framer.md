# Framer
- [`http-2/lib/http/2/framer.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/framer.rb)

## `#parse`
- 引数に与えられたHTTP/2フレームのデコードを行う
1. `frame = read_common_header(buf)`
2. フレームにパディングが含まれている場合は削除 `FRAME_TYPES_WITH_PADDING.include?(frame[:type])`
3. フレームタイプに応じて`frame`に値を格納
4. フレームを返す

## `#read_common_header`
- 共通のヘッダをフレームに読み出す

```ruby
{:length => Integer, :type => Symbol, :flags => Symbol[], :stream => Integer }
```
