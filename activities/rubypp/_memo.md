# 実装メモ
#### 代入パターン
1. `yyparse()`がソースコードを読み込む
2. `yyparse()`が`yylex()`を呼び出しトークンを取得する
    - [要作業] `++`に対して`+= 1`を表現する特殊なトークンを返す
3. `yyparse()`が構文規則部の定義に基づきトークンを還元し、アクション内でASTを構築する
    - [要作業] `command_asgn`規則に`| user_variable <TokenName>`を追加する
    - [要作業] 構文規則に`command_asgn : var_lhs tOP_ASGN lex_ctxt command_rhs`を同じアクションを追加
4. compile.cがASTをYARV命令列へ変換する -> メソッドディスパッチを行う

```c
command_asgn : var_lhs tOP_ASGN lex_ctxt command_rhs
{
  $$ = new_op_assign(p, $1, $2, $4, $3, &@$);
}
```

#### メソッド呼び出しパターン
1. `yyparse()`がソースコードを読み込む
2. `yyparse()`が`yylex()`を呼び出しトークンを取得する
    - [要作業] `++`に対してメソッド呼び出しを表すトークンを返す
3. `yyparse()`が構文規則部の定義に基づきトークンを還元し、アクション内でASTを構築する
    - [要作業] `method_call`規則に`| primary_value <TokenName>`を追加する
    - [要作業] `.`を必要としない改造版`new_qcall()` / `NEW_QCALL` (`NODE_CALL`を返す) を追加する
    - [要作業] `| primary_value <TokenName>`のアクションで改造版`new_qcall()`を呼ぶ
4. compile.cがASTをYARV命令列へ変換する -> メソッドディスパッチを行う
    - スタックにレシーバをpush
    - スタックに引数1をpush
    - メソッド`+`を実行
    - [要作業] Numericに`++`メソッド定義
