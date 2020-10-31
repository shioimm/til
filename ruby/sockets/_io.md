# class IO
- [class IO](https://docs.ruby-lang.org/ja/2.6.0/class/IO.html)

## ファイルディスクリプタ番号の取得
### `#fileno`
- `fileno` -> Integer
  - Socketオブジェクトのファイルディスクリプタ番号を返す

## 読み込み(`read(2)`)
### `#read`
- `read(length = nil, outbuf = "")` -> String | nil
  - 指定したサイズのデータを読み込む
    - データが指定したサイズに満たない場合、処理がブロックされる
  - サイズを指定しない場合、EOFまで読み込む
    - EOFがない場合、処理がブロックされる

### `#readpartial`
- `readpartial(maxlen, outbuf = "")` -> String
  - 指定したサイズを上限としてデータを読み込む
    - データが指定したサイズに満たない場合、読み込める限りのデータを読み込む

### `#read_nonblock`
- `read_nonblock(maxlen, outbuf = nil, exception: true)` -> String | Symbol | nil
  - IOをノンブロッキングモードに設定し、指定したサイズを上限としてデータを読み込む
    - データが指定したサイズに満たない場合、読み込める限りのデータを読み込む
    - データが送信されていない場合、`Errno::EAGAIN`を返す -> `IO.select` -> `retry` させる
  - `Errno::EAGAIN` / `Errno::EWOULDBLOCK`が発生した場合
    例外オブジェクトに対して`IO::WaitReadable`が`extend`される

## 書き込み(`write(2)`)
### `#write`
- `write(*str)` -> Integer
  - 指定した全てのデータをストリームに対して書き込む

### `#write_nonblock`
- `write_nonblock(string, exception: true)` -> Integer | `:wait_writable`
  - IOをノンブロッキングモードに設定し、指定したデータをストリームに対して書き込む
  - 書き込みがブロックされた場合はそれ以上データを書き込まず書き込みサイズを返す
  - 書き込みがブロックされている場合は`Errno::EAGAIN`が返される

## データ待ち状態(`select(2)`)
### `.select`
- `select(reads, writes = [], excepts = [], timeout = nil)` -> [[IO]] | nil
  - ノンブロッキングモードのIOにおいて`Errno::EAGAIN`が発生する場合、
    指定のソケット群を監視し、読み書き可能な状態になるまで処理をブロックする
    - `reads` - 読み込み待ちするソケット群(読み込み可能なデータの到着を待つ)
    - `write` - 書き込み待ちするソケット群(ソケットが書き込み可能になるまで待つ)

## バッファリング
- 参照: Working with TCP Sockets Chapter 8 Buffering
- 処理の正常終了-> データをカーネルに渡すことに成功した
- カーネルはデータのバッファリングを行うため、即時にストリームをフラッシュする保証はない

### 書き込みにおける最適なデータサイズ
- 原則的に全てのデータを書き込む
  データのチャンク処理はカーネルに任せる

### 読み込みにおける最適なデータサイズ
- 読み込み側では送信されてくるデータサイズの予測がつかない
- 受信したデータに基づいてプログラムを調整することによって
  読み込むべきデータサイズを最適化できる
- 主要なRubyプロジェクトにおいては16KBを読み込み上限として使用しているケースが多い
