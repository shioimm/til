### スカラと集成体型
- 参照: 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇1-1-11
- スカラ: 算術型(char、int、double、列挙型)およびポインタ
- 集成体型: スカラを組み合わせたもの(配列、構造体、共用体)

### shebang
- 実行ファイル内で使用するインタプリタを指定する行
```
/* bin/rails */

#!/usr/bin/env ruby

/* この行を実行する際、実際には引数として実行ファイルbin/railsが渡される */
```

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
