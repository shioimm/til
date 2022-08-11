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

## 参照
- プログラミングTypeScript
