# Prettier
- 参照・引用: [Prettier](https://prettier.io/)

## TL;DR
- opinionatedなコードフォーマッター
  - JavaScriptの他、JavaScriptによるライブラリやAltJSなど幅広い言語環境に対応

## ESLint/TSLintとの違い
- Prettierはコードの品質を保つために使われるべき
- ESLint/TSLintはバグの原因となる記述を検出するために使われるべき

### ESLintとの共存
- [ESLint と Prettier の共存設定とその根拠について](https://blog.ojisan.io/eslint-prettier)
- ESLintのスタイル設定を全部OFFにしESLintの中からPrettierを実行」

## Get Started
- [Install](https://prettier.io/docs/en/install.html)

### 設定方法
- `.prettierrc.json`に設定を記述する
  - フォーマットを無視する場合は`.prettierignore`に設定を記述する

### 実行方法
- `$ yarn prettier --write .` -> フォーマットを実行
- `$ yarn prettier --check .` -> フォーマットを確認
- huskeyにフックして実行する etc
