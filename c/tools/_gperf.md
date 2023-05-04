# gperf
- ハッシュ関数生成ツール
- 文字列のリストを入力すると、入力文字列に応じた値を検索するためのハッシュ関数とハッシュテーブルを
  C/C++コードで生成する
- MRIでは予約語のハッシュテーブルを定義する目的でgperfを使用してlex.cを生成し、lex.cはparse.cにincludeされる

## 参照
- [gperf](https://www.gnu.org/software/gperf/)
