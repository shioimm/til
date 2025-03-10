# SSR (Server Side Rendering): サーバーサイドレンダリング
- サーバーはクライアントからのリクエストに応じて、
  サーバーのJavaScript実行環境でレンダリングなどの計算を行い、
  UIコンポーネントを生成してHTMLとしてクライアントへ返す
- クライアントはサーバーで生成された静的なHTMLをロードし、
  動的なReact コンポーネントへ復元する (Hydration)

#### 特徴
- サイト表示の高速化が可能
- SEOの向上
- サーバーサイドでレンダリングするのでサーバーのCPU負荷増加
- サーバーとクライアントでUIを表示するためのロジックが分散

```js
const html = ReactDOMServer.renderToString(<App />)
```

#### SSG (Static Site Generation): 静的サイト生成
- 事前に静的ページを静的ファイルとして生成し、デプロイする
