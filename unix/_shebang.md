# 解釈実行ファイル(shebang)
- `#!`から始まるテキストファイル
  - `#!`の後に引数として渡したファイルを実行する
  - `/usr/local/bin/`ディレクトリなどに置く(パスを通しておく: `$ export PATH=$PATH:~/bin`)

```
#!/path/to/実行ファイル 引数
```

- 解釈実行ファイルはシステムコールの処理の一環としてカーネル内で認識される
- ファイル中にインタプリタのパス名を記述することによって
  スクリプトファイルを外部コマンドとして実行できるようになる

```sh
# ./xxx

#!/bin/sh

echo 'Hello'
```
- shebangに引数`/bin/sh`を渡す
- shebang以降の行を全て`/bin/sh`に渡す(`/bin/sh`で実行する)

```
# 実行許可を与える
$ chmod u+x xxx

# 外部コマンドとして実行する
$ ./xxx
Hello
```

#### Rubyスクリプトの場合
```sh
#!/usr/bin/env ruby
# envコマンドを使用することでPATHからRubyインタープリタを探索する

puts 'Hello'
```

## 参照
- [作業の自動化、謎のおまじない shebang（シバン）、PATH を設定する](https://fjord.jp/kuroigamen/8.html)
- 詳解UNIXプログラミング第3版 8. プロセスの制御
