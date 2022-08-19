# `useSWR`

```js
import useSWR from 'swr'

// const fetchData = (url: string): Promise<any> => fetch(url).then(res => res.body);

const App = () {
  const { data, error } = useSWR('/api/...', fetchData)
  // 返り値としてresolveした値、もしくはundefined (サスペンド状態) を返す

  if (error) return <div>failed to load</div>
  if (!data) return <div>loading...</div>

  return <div>{data}</div>
}
```

## 参照
- [SWR](https://swr.vercel.app/)
