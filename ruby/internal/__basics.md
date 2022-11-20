# Rubyファイルの実行フロー
1. ビルド
    - insns.defを読み込み
    - YARV命令列のインタプリタとなる関数`vm_exec_core()`にvm.incとvmtc.incをinclude
2. 実行ファイルの読み込み
3. `yyparse()`の実行 -> `yylex()`からトークンを取得 -> トークンを還元し、還元にフックして構文木を構築する
4. compile.cを実行し、構文木をYARV命令列に変換
5. `vm_exec_core()`をYARV命令列を実行
