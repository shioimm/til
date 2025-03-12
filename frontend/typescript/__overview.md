# TypeScript
- `tsc` - TypeScriptコンパイラ (コマンドラインアプリケーション・Node.jsが必要)
- tsconfig.json - 当該TSプロジェクトの設定ファイル (ルート直下に必要)
- リテラル型 - ただ1 つの値を表し、それ以外の値は受け入れない型

## コンパイルフロー
1. [TS] TypeScriptソースをTypeScript ASTへ変換
2. [TS] TypeScript ASTに対する型チェックを実行
3. [TS] TypeScript ASTをJavaScriptソースへ変換
4. [JS] JavaScriptソースをJavaScript ASTへ変換
5. [JS] JavaScript ASTをバイトコードへ変換
6. [JS] バイトコードがランタイムによって評価される

## TSプロジェクトの最小構成

```
projects/
├── node_modules/
├── src/
│ └── index.ts
├── dist/
│ └── index.ts # コンパイル時に自動生成される
├── package.json
├── tsconfig.json
└── tslint.json

# コンパイル
# $ ./node_modules/.bin/tsc
# 実行
# $ node ./dist/index.js
```

## 宣言による型/値の生成

| キーワード | 型を生成する | 値を生成する |
| -          | -            | -            |
| class      | ○            | ○            |
| enum       | ○            | ○            |
| interface  | ○            | ×            |
| type       | ○            | ×            |
| function   | ×            | ○            |
| namespace  | ×            | ○            |
| const      | ×            | ×            |
| let        | ×            | ×            |
| var        | ×            | ×            |

## 宣言によるマージ

| -                | 値 | クラス | 列挙型 | 関数 | 型エイリアス | インターフェース | 名前空間 | モジュール |
| -                | -  | -      | -      | -    | -            | -                | -        | -          |
| 値               | ×  | ×      | ×      | ×    | ○            | ○                | ×        | -          |
| クラス           | ×  | ×      | ×      | ×    | ×            | ○                | ○        | -          |
| 列挙型           | ×  | ×      | ○      | ×    | ×            | ×                | ○        | -          |
| 関数             | ×  | ×      | ×      | ×    | ○            | ○                | ○        | -          |
| 型エイリアス     | ○  | ×      | ×      | ○    | ×            | ×                | ○        | -          |
| インターフェース | ○  | ○      | ×      | ○    | ×            | ○                | ○        | -          |
| 名前空間         | ×  | ○      | ○      | ○    | ○            | ○                | ○        | -          |
| モジュール       | -  | -      | -      | -    | -            | -                | -        | ○          |

## 参照
- プログラミングTypeScript
