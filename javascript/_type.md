# 型
### プリミティブ型 (基本型)
- 真偽値
- 数値 - e.g. 42, 3.14159
- 巨大な整数 - e.g. 9007199254740992n (ES2020~)
- 文字列
- シンボル - e.g. Symbol("sym") (ES2015~)
- undefined
- null

#### falsyな型
- false
- undefined
- null
- 0
- 0n
- NaN
- "" (空文字列)

#### auto boxing
- 文字列や数値などのプリミティブ型を、プロパティを持つラッパーオブジェクトに自動変換する機能
  - `null` / `undefined`は対象外

```js
const str = "abc";

// str -> new String(str) 暗黙のボックス化

str.length; // フィールドの参照
str.toUpperCase(); // メソッド呼び出し
```

| プリミティブ型 | ラッパーオブジェクト |
| -              | -                    |
| boolean        | Boolean              |
| number         | Number               |
| string         | String               |
| symbol         | Symbol               |
| bigint         | BigInt               |

### オブジェクト (複合型)
- プリミティブ型以外のデータ
  - オブジェクト
  - 配列
  - 関数
  - 正規表現
  - Date etc

## 参照
- [ボックス化 (boxing)](https://typescriptbook.jp/reference/values-types-variables/boxing)
