# Lex / Flex
- 字句解析器ジェネレータ
- テキスト中の字句のパターンを認識しトークンを割り出すためのプログラムを生成する
- `$ lex <FileName>.l`コマンドでコンパイルすることによってlex.yy.cファイルを作成し、
  `yylex()`関数が利用できるようになる
- FlexはLexの性能を改善した上位互換

## 文法ファイル

```
// 宣言部
%{
  #include "<FileName>.tab.h" // yaccのヘッダファイルのinclude
%}

// 正則表現部
%%
Hello { return GREETING; }
\n    return 0;
.     return yytext[0];

// プログラム部
%%
```

#### 宣言部
- 正則表現部やプログラム部で使用する変数、関数、マクロを宣言する
  - トークン種別番号を表す定数宣言など (yaccを使用する場合は自動生成される)

#### 正則表現部
- 正則表現とそれが認識された際のアクション (Cプログラム) の組みを記述する
- `return`でトークンを返す
- `0`を返すと`yyparse()`が終了する
- `yytext[INDEX]`で入力文字列にアクセスできる

#### プログラム部
- 字句解析で使用する補助関数を記述する

## 参照
- コンパイラ入門 構文解析の原理とlex/yacc, C言語による実装
- [westes/flex: The Fast Lexical Analyser](https://github.com/westes/flex)
