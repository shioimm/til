# mrubyの実行
#### `.rb`
- prog.rbをmrubyコマンドで実行する

#### `.rb` -> `.mrb`
1. prog.rbをmrbcコマンドでmrubyバイトコードファイルprog.mrbへコンパイルする
2. prog.mrbをmrubyコマンドで実行する

#### `.rb` -> `.c` -> 実行ファイル
1. prog.rbををmrbcコマンドでCソースファイルprog.c (`prog`関数) へコンパイルする
2. Cソースファイルmain.cの中から`prog`関数を呼び出す
3. main.cとprog.cをgccでリンクし実行ファイルmainへコンパイルする
4. 実行ファイルmainを実行する

#### `#<method>` -> `.c` -> 実行ファイル
1. prog.rb内にメソッド`#prog`を定義する
2. Cソースファイルmain.c内からprog.rbをファイルとして読み込む
3. main.c内から`#prog`をmrubyメソッドとして呼び出す
4. main.cをgccで実行ファイルmainへコンパイルする
5. 実行ファイルmainを実行する
