# keyof
- オブジェクトのすべてのキーを文字列リテラル型のUnion型として取得

```ts
type T = {
  k1: {
    k2: string
    k3: {
      k4: string
      k5: string
    }[]
  }
}

type TKeys  = keyof T       // 'k1'
type K1Keys = keyof T['k1'] // 'k2' | 'k3'

// ルックアップと組み合わせ
type Get = {
  <O extends object, K extends keyof O>(o: O, k: K): O[K]
}

let get: Get = (o, k) => return o[k]
```

## 参照
- プログラミングTypeScript
