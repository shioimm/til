# Windows環境でRubyをビルド後、ライブラリをロードできない
#### 事象

```ruby
# test.rb

require_relative 'ext/socket/lib/socket
```

```
# ruby.exe = ビルド済みのRuby

> ruby.exe test.rb
```

を実行した際、`cannot load such file -- socket.so` になる

#### 解決
- 環境変数`RUBYLIB`にビルドしたライブラリへのパスを設定する

```
# pwd の直下に.ext/x64-mingw-ucrtがあること

> set RUBYLIB=%cd%\.ext\x64-mingw-ucrt
> echo %RUBYLIB%
```

で、`ruby.exe test.rb`を実行する
