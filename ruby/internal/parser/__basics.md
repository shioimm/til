# 構文解析
## パーサの構築手順
1. 文法規則parse.yの記述
2. parse.yをyaccコマンドにかけ、パーサコードy.tab.cを生成
3. y.tab.cをparse.cにmv
4. 予約語入力ファイルをgperfにかけ、lex.cを生成
5. lex.cをparse.cにinclude
6. parse.cをコンパイル (cc) し、パーサ実行ファイルparse.oを生成

## 字句解析・構文解析のコールグラフ
1. (ast.rb) `Primitive.ast_s_of` -> (ast.c) `static VALUE ast_s_of()`
2. Rubyの文字列オブジェクト、IOオブジェクト、`AbstractSyntaxTree.of`などからプログラムの情報を読み込む
    - `parser_compile_string()` (`rb_parser_compile_string()`、`rb_parser_compile_string_path()`)
    - `rb_parser_compile_file_path()`
    - `rb_parser_compile_generic()`
3. `yycompile()`
    - 1から渡された情報からソースコードを読み込み、最終的にASTを返す
4. `yycompile0()`
5. `yyparse()` が `yylex()` を呼び出し、トークンを取得する
6. `yylex()` がトークンを切り出して `yyparse()` に返す
7. `yyparse()` がトークンをセマンティックスタックにシフトする
8. `yyparse()` が `yyreduce` に遷移する
9. `yyreduce()` がセマンティックスタックのトークンを構文規則部の定義に基づいて還元する
10. `yyparse()` が `yynewstate` に遷移する -> `yychar = YYEMPTY` の場合は再び `yylex()` を呼ぶ

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- [第11章 状態付きスキャナ](https://i.loveruby.net/ja/rhg/book/contextual.html)
