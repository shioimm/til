# 構文解析
## パーサの構築手順
1. 文法規則parse.yの記述
2. parse.yをyaccコマンドにかけ、パーサコードy.tab.cを生成
3. y.tab.cをparse.cにmv
4. 予約語入力ファイルをgperfにかけ、lex.cを生成
5. lex.cをparse.cにinclude
6. parse.cをコンパイル (cc) し、パーサ実行ファイルparse.oを生成

## 字句解析・構文解析のコールスタック
1. (ast.rb) `Primitive.ast_s_of` -> (ast.c) `static VALUE ast_s_of()`
2. Rubyの文字列オブジェクト、IOオブジェクト、`AbstractSyntaxTree.of`などからプログラムの情報を読み込む
    - `parser_compile_string()` (`rb_parser_compile_string()`、`rb_parser_compile_string_path()`)
    - `rb_parser_compile_file_path()`
    - `rb_parser_compile_generic()`
3. `yycompile()`
    - 2から渡された情報からソースコードを読み込む
    - 最終的に `rb_ast_t` へのポインタを返す
4. `yycompile0()`
    - 3から `parser_params` を受け取り、 `yyparse()` を呼び出す
5. `yyparse()`
    - yysetstateに移行し、その後yybackupに移行する
6. `yyparse()` (yybackup)
    - lookaheadトークンを参照せずに`YYPACT[STATE-NUM]`から現在の状態を取得
    - 現在の状態が `yypact_value_is_default` の場合、yydefaultに移行
    - lookaheadトークンが必要な場合、 `yylex()` を呼び出す
7. `yylex()`
    - トークンを切り出して `yyparse()` に返す
8. `yyparse()` (yybackup)
    - lookaheadトークンと現在のセマンティックスタックを確認し、
      還元可能な状態の場合yyreduce、そうでない場合yynewstateへ移行する
9. `yyparse()` (yyreduce)
    - セマンティックスタックのトークンを構文規則部の定義に基づいて還元し、yynewstateへ移行する
10. `yyparse()` (yynewstate)
    - 次のステートに移行する
    - 移行先がyybackupであり、 `yychar == YYEMPTY` の場合は再び `yylex()` を呼ぶ

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- [第11章 状態付きスキャナ](https://i.loveruby.net/ja/rhg/book/contextual.html)
