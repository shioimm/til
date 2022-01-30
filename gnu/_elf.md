# ELF (Executable and Linkable Format)
- GNU/Linuxにおける標準バイナリフォーマット
  - コンパイラが生成するオブジェクト (オブジェクトファイル`.o`) と
    ライブラリとリンクされた実行ファイル (共有オブジェクト`.so`) において共通して用いられる
- 従来使用されていた`a.out` / `COFF`形式の後継
- 動的な共有ライブラリの利用とC++のサポートが容易
- ELFのヘッダ情報としてELF形式のバイナリやアーカイブのシンボルなどが含まれる

## 参照・引用
- [Executable and Linkable Format](https://ja.wikipedia.org/wiki/Executable_and_Linkable_Format)
- [実行ファイル形式のELFって何？](https://www.itmedia.co.jp/help/tips/linux/l0448.html)
