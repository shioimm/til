# Prettier (コードフォーマッタ)
#### ESLint / TSLintとの違い
- Prettier - コードの品質を保つ
- ESLint / TSLintはバグの原因となる記述を検出する
- [ESLint と Prettier の共存設定とその根拠について](https://blog.ojisan.io/eslint-prettier)
  - ESLintのスタイル設定を全部OFFにしESLintの中からPrettierを実行」

### Usage
#### 設定
- [Install](https://prettier.io/docs/en/install.html)
- .prettierrc.jsonに設定を記述する
- フォーマットを無視する場合は.prettierignoreに設定を記述する

#### 実行
- `$ yarn prettier --write .` -> フォーマットを実行
- `$ yarn prettier --check .` -> フォーマットを確認
- huskyにフックして実行する etc

## prettier-standard
- prettierと標準ルールで設定されたeslintのルールを使ったフォーマットツール

### Usage
- package.jsonに実行したい処理を記述

```json
{
  "scripts". {
    "format". "prettier-standard --format"
  }
}
```

## 参照
- [Prettier](https://prettier.io/)
- [prettier-standard](https://github.com/sheerun/prettier-standard)
