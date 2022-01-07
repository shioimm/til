# 構文解析
#### パーサの構築手順
1. parse.yの記述
2. 予約語入力ファイルをgperfにかけ、lex.cを生成
3. lex.cをparse.yにinclude
4. parse.yをyaccコマンドにかけ、y.tab.cを生成
5. y.tab.cをparse.cにmv
6. parse.cをコンパイル (cc) しパーサの実行ファイルparse.oを生成

#### parse.yユーザー定義部に定義される補助関数
- パーサインターフェイス
- スキャナ関連
- 構文木の構築
- 意味解析
- ローカル変数の管理
- IDの実装

## 参照
- [第10章 パーサ](https://i.loveruby.net/ja/rhg/book/parser.html)
