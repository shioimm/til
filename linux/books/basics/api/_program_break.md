# プログラムブレーク
### `brk(2)`
- 指定のアドレス位置へプログラムブレークを移動させる

#### 引数
- `*end_data_segment`を指定する↲
  - `*end_data_segment` - 新しいプログラムブレーク
    - 仮想メモリはページ単位に割り当てられるため、ページ境界へ丸め上げられる

#### 返り値
- 数値0
  - エラー時は数値-1

### `sbrk(2)`
- プログラムブレークに`increment`分の数値を加算してアドレス移動させる

#### 引数
- `increment`を指定する
  - `increment` - プログラムブレークに加算する数値
    - 新たに割り当てたメモリ領域の先頭アドレス

#### 返り値
- 数値0
  - エラー時は数値-1

## 参照
- 例解UNIX/Linuxプログラミング教室P185-224
- 詳解UNIXプログラミング第3版 7. プロセスの環境 / 8. プロセスの制御 / 9. プロセスの関係
- Linuxプログラミングインターフェース 6章
