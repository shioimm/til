### コンカレンシーとパラレリズム
- 参照: [Rubyのスケール時にGVLの特性を効果的に活用する（翻訳）](https://techracho.bpsinc.jp/hachi8833/2020_05_27/92042)
- コンカレンシー: 並列処理
  - Ex. 一人のレジ係がn人の顧客に対して同時に1:nで対応
- パラレリズム: 平行処理
  - Ex. n人のレジ係がn人の顧客に対して同時に1:1で対応
- プロセス
  - 一つ以上のスレッドを持つ
  - メモリアロケーションやファイルディスクリプタなどを持つ
  - Ex. レジカウンター
- スレッド
  - カーネルによってスケジューリングされるとコードを実行する
  - スレッドローカルストレージ、スタックなどを持つ
  - Ex. レジ係

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

### gccとは
- 引用: [gcc  【 GNU Compiler Collection 】  GNU C Compilier](http://e-words.jp/w/gcc.html)
- GNUプロジェクトが開発・公開しているコンパイラ
- 標準でC、C++、Objective-C、Fortran、Java、Ada、Goのコンパイラを同梱
- `gcc` -> gcc内のCコンパイラの名称および実行ファイル名
