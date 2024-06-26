# 汎用命令セット
- データ転送命令
  - `MOV`(汎用レジスタ、セグメントレジスタ、メモリロケーション間でデータを転送)
    - 即値をレジスタにコピー
    - レジスタの値を別のレジスタにコピー
    - メモリの値をレジスタにコピー
    - 即値をメモリに格納
    - レジスタの値をメモリに格納
  - `MOVZX`(転送して符号で拡張) / `MOVSX`(転送して0で拡張)
    - レジスタの値をより大きなレジスタに0拡張・符号拡張してコピーする
    - メモリの値をより大きなレジスタに0拡張・符号拡張してコピーする
  - `XCHG`(交換)
    - レジスタの値同士を交換
    - レジスタの値とメモリの値を交換
  - `PUSH`(スタックにプッシュ)
    - 即値をスタック上にプッシュ
    - レジスタの値をスタック上にプッシュ
    - メモリの値をスタック上にプッシュ
  - `POP`(スタックにポップ)
    - スタックからレジスタへポップ
    - スタックからメモリへポップ
  - `LEA`(メモリロケーションをレジスタへ転送)
    - メモリのアドレスをレジスタに読み込む
  - その他
- 2進算術命令 - フラグを変更させる
  - `ADD` / `ADC`(加算命令)
    - レジスタriに即値cを加える
    - レジスタriにレジスタrjの値を加える
    - レジスタriにメモリの値を加える
    - メモリの値に即値cを加える
    - メモリの値にレジスriタの値を加える
  - `SUB` / `SBB`(減算命令)
    - レジスタriから即値cを減じる
    - レジスタriからレジスタrjの値を減じる
    - レジスタriからメモリの値を減じる
    - メモリの値から即値cを減じる
    - メモリの値からレジスタriの値を減じる
  - `MUL`(符号なし整数の乗算命令)
    - レジスタraの値にレジスタriの値を掛け、結果をrd:raに格納する
    - レジスタraの値にメモリの値を掛け、結果をrd:raに格納する
  - `IMUL`(符号付き整数の乗算命令)
    - レジスタraの値にレジスタriの値を掛け、結果をrd:raに格納する
    - レジスタraの値にメモリの値を掛け、結果をrd:raに格納する
    - レジスタriの値にレジスタriの値を掛ける
    - レジスタriの値に即値cを掛ける
    - レジスタriの値にメモリの値を掛ける
    - レジスタriの値に即値cを掛け、結果をレジスタrjに格納する
    - メモリmの値に即値cを掛け、結果をレジスタriに格納する
  - `DIV`(符号なし整数の除算命令) / `IDIV`(符号付き整数の除算命令)
    - レジスタriの値をレジスタrjの値で割る
    - レジスタriの値をメモリmの値で割る
  - `INC`(インクリメント命令)
    - レジスタriに1を加える
    - メモリの値に1を加える
  - `DEC`(デクリメント命令)
    - レジスタriから1を減じる
    - メモリの値から1を減じる
  - `CMP`(比較命令)
    - 二つのオペランドの値の差の有無を計算する
  - 符号変更命令
- 10進算術命令
  - パックドBCD調整命令
  - アンパックドBCD調整命令
- 論理演算命令
  - `AND` / `OR` / `XOR`
    - レジスタriと即値cの論理積 / 論理和 / 排他的論理和を計算しレジスタriに格納する
    - レジスタriとメモリmの値の論理積 / 論理和 / 排他的論理和を計算しレジスタriに格納する
    - メモリmの値と即値cの論理積 / 論理和 / 排他的論理和を計算しレジスタriに格納する
    - レジスタriと即値cの論理積 / 論理和 / 排他的論理和を計算しレジスタriに格納する
    - メモリmの値とレジスタriとの論理積 / 論理和 / 排他的論理和を計算しメモリmに格納する
  - `NOT`
    - オペランドの値に含まれている各ビットの0と1を反転する
- ビットのシフト命令
  - `SAL` / `SHL`(左シフト)
    - レジスタriを即値cの回数だけ左方向にシフトする
    - レジスタriをレジスタrjの回数だけ左方向にシフトする
    - メモリmの値を即値cの回数だけ左方向にシフトする
    - メモリmの値をレジスタriの回数だけ左方向にシフトする
  - `SAR`(算術右シフト) / `SHR`(論理右シフト)
    - レジスタriを即値cの回数だけ右方向にシフトする
    - レジスタriをレジスタrjの回数だけ右方向にシフトする
    - メモリmの値を即値cの回数だけ右方向にシフトする
    - メモリmの値をレジスタriの回数だけ右方向にシフトする
- ビットのダブルシフト命令
- ビットのローテート命令
- ビット命令とバイト命令
- 制御転送命令
  - `JMP`(無条件転送命令)
    - (EIPレジスタを直接変更することはできない)
    - 即値cの示す相対アドレスへジャンプする
    - レジスタriの値のアドレスへジャンプする
    - メモリmに格納されているアドレスへジャンプする
  - `CALL`(サブルーチン呼び出し)
    - (コール = リターンアドレスをスタックにプッシュした上でEIPレジスタを変更)
    - 現在のアドレス + 即値cのアドレス(相対アドレス)をコールする
    - レジスタriの値のアドレスをコールする
    - メモリmに格納されているアドレスをコールする
  - `RET`(サブルーチンから戻る)
    - 呼び出し元にリターンする
    - 呼び出し元にリターンし、スタックからcバイト捨てる(不要となったスタック上の引数を捨てる)
  - `JCC`(条件付き転送命令)
    - 条件ccが満たされている場合、現在のアドレス + 定数cアドレス(相対アドレス)にジャンプする
- ストリングの操作
- I/O命令
- ENTER命令とLEAVE命令
- フラグ制御(EFLAGS)命令
- セグメントレジスタ命令
- その他の命令

## 参照
- 独習アセンブラ
