# クラス

```ts
class Person {
}

const person = new Person();
```

## 抽象クラス

```ts
abstract class AbstractKlass {
  method() {
    // 実装が継承される
  }

  abstract abstractMethod(): boolean; // 子クラスに実装
}

class Klass extends AbstractKlass {
  abstractMethod() {
  }
}
```

## インターフェース

```ts
interface I1 {
  m1(): void;
}

interface I2 {
  m2(): void;
}

class Klass implements I1, I2 {
  m1(): void {
    // 実装
  }

  m1(): void {
    // 実装
  }
}
```

- 同じ名前のインターフェースを宣言した場合、それぞれのインターフェースの型がマージされる

### 継承
```ts
interface extentedObj extends Obj {
  prop2: number // prop2プロパティを強制
}

const objHasProp2: extentedObj = {
  name: 'abc',
  age: 99
}
```

### 関数

```ts
interface DoubleValues {
  (x: number, y: number): number
}

let doubleFn: DoubleValues = (x: number, y: number) => {
  return (x ** y)
}
```

### 型エイリアスとの違い
- インターフェース -  型の宣言
- 型エイリアス -  型に名前をつける

| 機能                       | インターフェース   | 型エイリアス                                   |
| -                          | -                  | -                                              |
| 継承                       | 可能               | 不可 (インターセクション型で代替可能)          |
| プロパティのオーバーライド | 上書き or エラー   | フィールド毎にインターセクション型が計算される |
| 同名の宣言                 | 定義がマージされる | エラーが発生                                   |
| Mapped Type                | 使用不可           | 使用可能                                       |

## 参照
- [クラス (class)](https://typescriptbook.jp/reference/object-oriented/class)
- [インターフェース (interface)](https://typescriptbook.jp/reference/object-oriented/interface)
