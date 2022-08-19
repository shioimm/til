# `useEffect`
- render後にコールバックを実行する

```js
useEffect(コールバック関数, 監視対象の配列)
```

```js
// render後に一回だけコールバックを実行
useEffect(() => {
  f()
}, [])

// 監視対象が変更されるたびコールバックを実行
const [count, setCount] = useState(0);

useEffect(() => {
  f()
}, [count])

setCount(count++)

// コンポーネントのアンマウント時にコールバックを実行 (クリーンアップ関数)
useEffect(() => {
  return f()
}, [])
```
