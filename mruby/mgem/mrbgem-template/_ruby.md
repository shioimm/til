# Rubyスクリプト用ファイルテンプレート
- `mrblib/mgemの名前.rb`

```ruby
class mgemの名前
  def bye
    self.hello + "bye"
  end

  # --bin-nameオプションを付与した場合:
  def __main__(argv) # argv = ARGV
    # メソッド内に記述した内容を $ ./mruby/bin/バイナリの名前 コマンドライン引数 で実行可能
    raise NotImplementedError, "Please implement Kernel#__main__ in your .rb file"
  end
end
```

## 参照
- [mruby-mrbgem-template](https://github.com/matsumotory/mruby-mrbgem-template)
- Webで使えるmrubyシステムプログラミング入門 Section019
