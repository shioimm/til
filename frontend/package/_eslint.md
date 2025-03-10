# ESLint (リンタ)
#### Prettierとの違い
- Prettier - コードの品質を保つ
- ESLint / TSLintはバグの原因となる記述を検出する
- [ESLint と Prettier の共存設定とその根拠について](https://blog.ojisan.io/eslint-prettier)
  - ESLintのスタイル設定を全部OFFにしESLintの中からPrettierを実行」

### Usage
#### 設定
- [Getting Started with ESLint](https://eslint.org/docs/user-guide/getting-started)
- [Configuring ESLint](https://eslint.org/docs/user-guide/configuring)
- .eslintrc.jsに設定を記述する
- package.json内の`eslintConfig`項目を記述する
- Configuration Comments: コメントによってコードの中に直接設定を埋め込む

#### 実行方法
- [Command Line Interface](https://eslint.org/docs/user-guide/command-line-interface)
- `$npx eslint "lib/**"`を実行する
- huskeyにフックして実行する etc

## 参照・引用
- [ESLint](https://eslint.org/)
