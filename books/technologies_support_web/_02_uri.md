# Webを支える技術 まとめ02
- 山本陽平 著

## 02 URI
```
https://coe:pass@blog.example.com:8000/search?q=test&debug=true#n10

- https -> スキーマ
- coe -> ユーザ名
- pass -> パスワード
- blog.example.com -> ドメイン名
- 8000 -> ポート
- /search -> パス
- q=test&debug=true -> クエリパラメータ
- #n10 -> URIフラグメント
```

- ベースURI -> 相対URIの起点となるURL
  - `<head>`要素の中で`<base>`要素として指定できる
``html`
<head>
  <base href='https://example.com'>
```
