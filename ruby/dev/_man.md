# manの動作確認

```
# (man/ruby.1 を書き換える)

$ mkdir -p ~/src/man/man1

# (man/ruby.1 を書き換えた後、cpすると内容が更新される)
$ cp ~/src/ruby/man/ruby.1 ~/src/man/man1

$ export MANPATH=~/src/man/:$MANPATH
$ echo $MANPATH # => /Users/misaki-shioi/src/man/:...

$ man ruby

# リセット
$ unset MANPATH
```
