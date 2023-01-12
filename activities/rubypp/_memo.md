# メモ
- Ken ThompsonによってB言語に導入されたのがはじまり
  - [Increment and decrement operators: History](https://en.wikipedia.org/wiki/Increment_and_decrement_operators#History)
  - [The Development of the C Language: More History](http://www.bell-labs.com/usr/dmr/www/chist.html)

```
> ++の動作が本質的に「変数を操作する」ものであるため，変数がオブジェクトでないRubyでは導入できないでいます．++や--の「オブジェクト指向的意味」がRubyの他の部分と整合性を保ったまま定義できれば採用したいのですが…．
```

- `++` / `--`は変数を操作するためのものである一方、Rubyには「変数」オブジェクトが存在しないため、
  オブジェクト指向言語としての整合性を保ちつつ同演算子を導入することが難しい
  - [Ruby にインクリメント演算子のようなものが無い理由](https://blog.tokoyax.com/entry/ruby/increment)
  - [Subject: [ruby-talk:02710] Re: X++?](https://web.archive.org/web/20170421214136/blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/2710)
  - [decrement and increment](https://bugs.ruby-lang.org/issues/1432)
