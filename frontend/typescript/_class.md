# クラス

```ts
// Klassクラスを定義すると
// 1. 型の名前空間にKlass型、値の名前空間にKlassクラスが定義される

class Klass {
  constrator() {}
  method() {}
}

let k: Klass = new Klass // Klass型のKlassインスタンスkを生成

// 2. インスタンス型 (Klass) とコンストラクタ型 (typeof Klass) が生成される
//   インスタンス型はメンバmethod()を持つシグネチャ
//   コンストラクタ型はメンバnew()を持つシグネチャ
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
interface Obj {
  prop1: string
}

interface extentedObj extends Obj {
  prop2: number
}

const ob: extentedObj = {
  prop1: 'string'
  prop2: 1
}
```

```ts
// リテラル型へ変換可能
interface Obj1 {
  prop: string
}

interface extentedObj1 extends Obj1 {
  prop: 'string'
}

// ユニオン型から絞り込み可能
interface Obj2 {
  prop: string | number
}

interface extentedObj2 extends Obj2 {
  prop: string
}

interface Obj3 {
  prop: string
}

// 継承元のプロパティに適合しない上書きは不可能
interface extentedObj3 extends Obj3 {
  prop: number // Error
}
```

### 宣言のマージ

```ts
interface Obj {
  prop: number
}

// 別の名前のプロパティを持つ同名のインターフェースを宣言した場合、プロパティがマージされる
interface Obj {
  prop0: string
}

// 同じ名前・異なる型のプロパティを持つ同名のインターフェースの宣言は不可能
interface Obj {
  prop: string // Error
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

| 機能                         | インターフェース       | 型エイリアス                                   |
| -                            | -                      | -                                              |
| 継承                         | 可能                   | 不可 (インターセクション型で代替可能)          |
| 継承によるプロパティの上書き | 上書き or エラー       | フィールド毎にインターセクション型が計算される |
| 同名の宣言                   | 定義をマージ or エラー | エラー                                         |
| Mapped Type                  | 使用不可               | 使用可能                                       |

## finalクラス

```ts
// constratorをprivateにすることによってクラスの拡張や直接的なインスタンス化を禁止する

class Klass {
  private constrator(private arg: number) {}

  // インスタンス化を行うメソッドを用意
  static create(arg: number) {
    return new Klass(arg)
  }
}

Klass.create(1)
```

## 参照
- [クラス (class)](https://typescriptbook.jp/reference/object-oriented/class)
- [インターフェース (interface)](https://typescriptbook.jp/reference/object-oriented/interface)
