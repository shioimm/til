# Rubyファイルの実行フロー
1. Rubyのビルド
    - VM Generatorがinsns.defを読み込み、VMが命令を実行するために必要なvmtc.incとvm.incを生成
2. Rubyのインストール
    - YARVの命令ディスパッチを行う`vm_exec_core()`にvm.incとvmtc.incをinclude
3. 実行ファイルの読み込み
4. `yyparse()`の実行 -> `yylex()`からトークンを取得 -> トークンを還元し、還元にフックして構文木を構築する
5. compile.cを実行し、構文木をYARV命令列に変換
6. `vm_exec_core()`関数でYARV命令列を実行
