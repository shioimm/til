# 構文解析
## パーサの構築手順
1. 文法規則parse.yの記述
2. parse.yをyaccコマンドにかけ、パーサコードy.tab.cを生成
3. y.tab.cをparse.cにmv
4. 予約語入力ファイルをgperfにかけ、lex.cを生成
5. lex.cをparse.cにinclude
6. parse.cをコンパイル (cc) し、パーサ実行ファイルparse.oを生成

## 字句解析・構文解析のコールグラフ
1. `parser_compile_string()` / `rb_parser_compile_file_path()` / `rb_parser_compile_generic()`
    - Rubyの文字列オブジェクト、IOオブジェクト、`AbstractSyntaxTree.of`などからプログラムの情報を読み込む
2. `yycompile()`
    - 1から渡された情報からソースコードを読み込み、最終的にASTを返す
3. `yycompile0()`
4. `yyparse()` が `yylex()` を呼び出し、トークンを取得する
5. `yylex()` がトークンを切り出して `yyparse()` に返す
6. `yyparse()` がトークンをセマンティックスタックにシフトする
7. `yyparse()` が `yyreduce` に遷移する
8. `yyreduce()` がセマンティックスタックのトークンを構文規則部の定義に基づいて還元する
9. `yyparse()` が `yynewstate` に遷移する -> `yychar = YYEMPTY` の場合は再び `yylex()` を呼ぶ

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- [第11章 状態付きスキャナ](https://i.loveruby.net/ja/rhg/book/contextual.html)
