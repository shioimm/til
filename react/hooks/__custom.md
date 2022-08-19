# カスタムフック

```js
// 1秒ごとにカウントアップした値を返す関数としてカスタムフック定義
const useTimer = () => {
  const [count, setCount] = useState(0)

  useEffect(() => {
    const timer = setInterval(() => {
      setCount(c => c++)
    }, 1000)

    return () => {
      clearInterval(timer);
    }
  }, [])

  return count
}

const Timer = () => {
  const count = useTimer()
  return <p>{count}</p>
}
```

## 参照
- WEB+DB PRESS Vol.129
