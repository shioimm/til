# ワンショットでコンテナを実行
1. ホストのカレントディレクトリ (`$PWD`) に`hello.rb`ファイルを用意
2. ホストのカレントディレクトリをコンテナの`/usr/src`ディレクトリにマウントし、
   コンテナの`/usr/src`ディレクトリで`ruby`コマンドをワンショットで実行

```
$ cat hello.rb
puts "Hello"

$ docker run --rm -v "$PWD":/usr/src -w /usr/src rubylang/ruby ruby hello.rb
Hello
```
