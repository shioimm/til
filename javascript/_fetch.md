# Fetch API
- ワンショットのクライアント起点のHTTPリクエストを行う関数(XMLHttpRequestの再設計)

### 特徴
- XMLHttpRequestよりもCORSの取扱いが制御しやすくなった
- JSの非同期処理の記述法であるPromiseに準拠
- キャッシュを細かく制御できる
- リダイレクトを細かく制御できる
- Referer Policyを制御できる
- Service Worker内からの外部接続手段として利用できる
  - Service Worker - アプリケーションのライフサイクルや通信内容をコントロールする仕組み
    - Webにネイティブアプリケーションの機能を持たせる取り組み(Progressive Web App)の一つ
    - Service WorkerはJavaScriptとサーバーの中間レイヤーとして動作する

## `fetch()`関数

```js
// GET

const response = await fetch("/path", { // 非同期通信なのでawaitが必要
  method: 'GET',
  mode: 'cors',
  credentials: 'include', // クロスオリジンの呼び出しであっても、常にクッキーを送信する
  cache: 'default',
  headers: {
    'Content-Type': 'application/json',
  },
});

if (response.ok) {
  const json = await response.json();
  // レスポンス200時に呼ばれる処理↲
}
```

```js
// POST

const response = await fetch("/path", {
  method: "POST",
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    'title': 'titleA',
    'body':  'bodyA',
  }),
});
```

### パラメータ

```js
// パラメータの生成
const params = new URLSearchParams();
params.set("id", "1");

// パラメータの解析
params.has("id");
params.get("id");
```

## 参照
- [Fetch API](https://developer.mozilla.org/ja/docs/Web/API/Fetch_API)
- [Fetch の使用](https://developer.mozilla.org/ja/docs/Web/API/Fetch_API/Using_Fetch)
- Real World HTTP 第2版
