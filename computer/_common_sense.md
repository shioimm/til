### segmentation faultとは
- 参照: [セグメンテーション違反](https://ja.wikipedia.org/wiki/%E3%82%BB%E3%82%B0%E3%83%A1%E3%83%B3%E3%83%86%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E9%81%95%E5%8F%8D)
- ソフトウェアの実行時に以下の条件で発生するエラー
  - アクセスが許可されていないメモリにアクセスしようとした場合
  - 許可されていない方法でメモリにアクセスしようとした場合
- Unixにおいては、不正なメモリにアクセスしようとしたプロセスはSIGSEGVシグナルを受け取る
```
[BUG] Segmentation fault at 0x0000000000000000
ruby 2.6.2p47 (2019-03-13 revision 67232) [x86_64-linux]

...略

[NOTE]
You may have encountered a bug in the Ruby interpreter or extension libraries.
Bug reports are welcome.
For details: https://www.ruby-lang.org/bugreport.html
Received 'aborted' signal
```

### gccとは
- 引用: [gcc  【 GNU Compiler Collection 】  GNU C Compilier](http://e-words.jp/w/gcc.html)
- GNUプロジェクトが開発・公開しているコンパイラ
- 標準でC、C++、Objective-C、Fortran、Java、Ada、Goのコンパイラを同梱
- `gcc` -> gcc内のCコンパイラの名称および実行ファイル名
