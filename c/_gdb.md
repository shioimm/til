# gdb
- 参照: [GDB: The GNU Project Debugger](https://www.gnu.org/software/gdb/)

## gdbでできること
- プログラムの動作に影響を与える可能性のあるコードを指定してプログラムを起動する
- 指定した条件によってプログラムを停止させる
- プログラムが停止したときに何が起こったのかを調べる
- プログラムの内容を修正し、結果を検証する

## Usage
### 起動
```sh
$ gdb デバッグする対象のバイナリ
```

### 実行
```sh
(gdb) run -e 'puts C.from_mruby' # mrubyからCのコードを実行

(gdb) run -n 5 # 対象のバイナリの行番号を指定して実行
```

### バックトレースを表示
```
(gdb) backtrace
```

### プログラムの停止箇所を表示
```
(gdb) list
```

### printデバッグ
```
(gdb) print xxxx
```

### 終了
```
(gdb) quit
```
