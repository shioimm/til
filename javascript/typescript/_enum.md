# enum
- デフォルトではインデックスと同じ数値が割り当てられるが上書きもできる

```js
enum Cities {
  Tokyo,      // 0
  Osaka = 10, // 10
  Fukuoka     // 11
}

let city: Cities = Cities.Fukuoka // => 11
```
