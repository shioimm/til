### IRBでRubyVM::AbstractSyntaxTree.ofを使えない理由
- 2019/8/22
- 参照: https://sinsoku.hatenablog.com/entry/2019/05/04/032007

 ```ruby
if (!NIL_P(lines = script_lines(path))) {
    node = rb_ast_parse_array(lines);
}
else if (RSTRING_LEN(path) == 2 && memcmp(RSTRING_PTR(path), "-e", 2) == 0) {
    node = rb_ast_parse_str(rb_e_script);
}
else {
    node = rb_ast_parse_file(path);
}
```

- 次の条件を確認している
  - [`SCRIPT_LINES__`](https://docs.ruby-lang.org/ja/latest/method/Object/c/SCRIPT_LINES__.html)が存在するか
  - `ruby -e`で実行された処理か
  - それ以外の処理か
- IRBでは`SCRIPT_LINES__`が存在しないため、最終行に処理が落ちるが、pathが存在しないためエラーになる
  - `Errno::ENOENT (No such file or directory @ rb_sysopen - (irb))`
- これを回避するには、`SCRIPT_LINES__`にソースコード（として記述している文字列）の配列を持たせる必要がある
  - [irbでRubyVM::AbstractSyntaxTree.ofを使って雑にASTを取る](https://qiita.com/hanachin_/items/bfd1dd0cf278e6f2d7b9)
