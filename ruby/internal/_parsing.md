# 構文解析
#### パーサの構築手順
1. 文法規則parse.yの記述
2. 予約語入力ファイルをgperfにかけ、lex.cを生成
3. lex.cをparse.yにinclude
4. parse.yをyaccコマンドにかけ、パーサコードy.tab.cを生成
5. y.tab.cをparse.cにmv
6. parse.cをコンパイル (cc) し、パーサ実行ファイルparse.oを生成

#### parse.yユーザー定義部に定義される補助関数
- パーサインターフェイス
- スキャナ関連
- 構文木の構築
- 意味解析
- ローカル変数の管理
- IDの実装

## Rubyの実行フロー
1. ソースプログラムのスキャン・トークナイズ
2. トークンの還元にフックするアクションで`rb_node_newnode`関数が呼ばれ
   ノードとなるRubyオブジェクト (RNode構造体) がCレベルで生成される
3. RNode構造体の構造がYARVによって命令列に置き換わる
4. YARV命令列の実行

## スキャナの状態`lex_state` (parse.y)
- 今スキャナを動作させたらどのように動くかを示す状態
- `lex_state` (parse.y) - スキャナの状態を示す変数 (`lex_state_bits` / `lex_state_e`)

## 構文木 RNode構造体 (node.h)
- Rubyプログラムはスキャン・パースされた後構文木に変換される
- RNode構造体はRubyオブジェクトであるためノードの生成と解放はRubyのGCによって管理される
- RNode構造体のflagsにはRubyのシステムフラグの他にノードの種類も保管される
  - ノードの種類によってRNode構造体のメンバu1, u2, u3共用体の用途が変わる
- ノードは`rb_node_newnode`関数 (parse.y) によって生成される

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
- [第11章 状態付きスキャナ](https://i.loveruby.net/ja/rhg/book/contextual.html)
- [第12章 構文木の構築](https://i.loveruby.net/ja/rhg/book/syntree.html)
