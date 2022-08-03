# 型エイリアス
```ts
type Obj = {
  nums: number[],
  func: (arg: boolean) => number[]
}

const obj: Obj = {
  nums: [1, 2, 3],
  func: function(arg: boolean): number[] {
    reuturn this.nums
  }
}
```

## 型エイリアスの宣言
```ts
// プリミティブ型
type Str = string;

// リテラル型
type OK = 1;

// 配列型
type Numbers = number[];

// オブジェクト型
type UserObject = { id: number; name: string };

// ユニオン型
type NumberOrNull = number | null;

// 関数型
type CallbackFunction = (value: string) => boolean;
```

## 参照
- [型エイリアスの使用例](https://typescriptbook.jp/reference/values-types-variables/type-alias#%E5%9E%8B%E3%82%A8%E3%82%A4%E3%83%AA%E3%82%A2%E3%82%B9%E3%81%AE%E4%BD%BF%E7%94%A8%E4%BE%8B)
