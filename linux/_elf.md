# Executable and Linkable Format
- 参照・引用: [Executable and Linkable Format](https://ja.wikipedia.org/wiki/Executable_and_Linkable_Format)
- 参照: [実行ファイル形式のELFって何？](https://www.itmedia.co.jp/help/tips/linux/l0448.html)
- 参照・引用: [オブジェクトファイルについて](http://shinh.skr.jp/binary/shdr.html)

## TL;DR
- GNU/Linuxにおける標準バイナリフォーマット
  - 実行ファイル、共有オブジェクト`.so`、オブジェクトファイル`.o`において共通して用いられる
  - 従来使用されていた`a.out` / `COFF`形式に比較し、
    動的な共有ライブラリの利用とC++のサポートに適している

## ヘッダ
- `$ readelf ファイル名`でヘッダ情報を表示できる
  - ヘッダ情報 - ELF形式のバイナリやアーカイブのシンボルなど

### ELFヘッダ
- ELF全体の情報、プログラムヘッダとセクションヘッダの情報が格納されている

### プログラムヘッダ
- 実行開始時にメモリにマップされるべきデータについての情報が格納されている
  - Ex. プログラムコード、初期化済みグローバル変数の領域

### セクションヘッダ
- プログラムを実行する時に必要なオブジェクトファイルの論理的な構造に関する情報が格納されている
