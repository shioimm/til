# ESLint
- オープンソースのリンター
- 対象のコードは自動的に修正される
- 独自のルールに従ってカスタマイズすることもできる
- すべてのルールは完全にプラグインできるように設計されている
- Node.jsで実装されており、npmによってインストールできる

## 特徴
- 構文解析にEspreeを使用
- コードのパターンを評価するためASTを使用
- 完全にプラグイン可能
  - すべてのルールはプラグイン
  - プラグインは追加することも可能

## Getting Started
- [Getting Started with ESLint](https://eslint.org/docs/user-guide/getting-started)

### 設定方法
- [Configuring ESLint](https://eslint.org/docs/user-guide/configuring)
- Configuration Comments: コメントによってコードの中に直接設定を埋め込む
- Configuration Files: JavaScript、JSON、YAMLなど設定ファイルを記述する
  - `.eslintrc.js` `.eslintrc.json` `.eslintrc.yml`
  - `package.json`内の`eslintConfig`項目

### 実行方法
- [Command Line Interface](https://eslint.org/docs/user-guide/command-line-interface)
- `$ npm i -g eslint`を実行する
- huskeyにフックして実行する etc

## 参照・引用
- [ESLint](https://eslint.org/)
