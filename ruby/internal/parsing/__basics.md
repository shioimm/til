# 構文解析
## パーサの構築手順
1. 文法規則parse.yの記述
2. parse.yをyaccコマンドにかけ、パーサコードy.tab.cを生成
3. y.tab.cをparse.cにmv
4. 予約語入力ファイルをgperfにかけ、lex.cを生成
5. lex.cをparse.cにinclude
6. parse.cをコンパイル (cc) し、パーサ実行ファイルparse.oを生成

## 字句解析・構文解析のコールスタック
1. `parser_compile_string()` / `rb_parser_compile_file_path()` / `rb_parser_compile_generic()`
2. `yycompile()`
3. `yycompile0()`
4. `yyparse()` -> `yylex()` -> `yyreduce()` -> `yynewstate()` -> `yylex()` ...

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- [第11章 状態付きスキャナ](https://i.loveruby.net/ja/rhg/book/contextual.html)
