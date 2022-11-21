# 実装メモ
#### 処理の流れ
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
