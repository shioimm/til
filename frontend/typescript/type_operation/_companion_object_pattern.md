# コンパニオンオブジェクトパターン (companion object pattern)
- 同じ名前を共有するオブジェクトとクラスをペアにする

```ts
// Currency.ts
type Unit = 'EUR' | 'GBP' | 'JPY' | 'USD'

export type Currency = {
  unit: Unit
  value: number
}
export let Currency = {
  from(value: number, unit: Unit): Currency {
    return {
      unit: unit,
      value
    }
  }
}

// Currency型とCurrency値はペアになる
```

```ts
import { Currency } from './Currency' // Currency型とCurrency値をまとめてimport

// Currency型として扱う
let amountDue: Currency = {
  unit: 'JPY',
  value: 83733.10
}

// Currency値として扱う
let otherAmountDue = Currency.from(330, 'EUR')
```

# 参照
- プログラミングTypeScript 6.3.4
