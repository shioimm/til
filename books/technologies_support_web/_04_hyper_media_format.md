# Webを支える技術 まとめ03
- 山本陽平 著

## 04 ハイパーメディアフォーマット
### HTML
- メディアタイプ -> text/htmlまたはapplication/xhml+xml
- 拡張子 -> \.html

#### ハイパーメディアフォーマットとしてのHTML要素
- `<a>` -> 他のWebページへのアンカー
- `<link>` -> Webページ同士の関係を指定 / `<head>`内で使用
- `<img>` / `object` ->  オブジェクトの埋め込み
- `<form>` -> リンク先URIに対してGET / POSTを発行
  - GETの場合 -> ターゲットURIと入力値からリンク先URIを生成
  - POSTの場合 -> ターゲットURIがリンク先URIとなり、リクエストボディに入力値が入る

#### 属性
- name属性(`<form>`) -> 対象とする要素のデータを示す名前
- rel属性(`<a>` / `<link>`)-> リンク元のリソースとリンク先のリソースがどのような関係にあたるか
```html
<link rel="stylesheet" hrf="http://example.jp/base.css" />
```

### JSON
- メディアタイプ -> application/json
- 拡張子 -> \.json

#### JSONP
- [XMLHttpRequest](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest)(Ajaxリクエストを生成するJSのAPIモジュール)はクロスドメイン通信を制限している
- JSONPは上記の制限を回避するために用いられる
```
// 例
1. index.htmlに次のコードが埋め込まれている
  - a. 引数で受け取った値をalert表示する関数fooを記述した<script>タグ
  - b. src="http://example.jp/hoge.json?callback=foo"を記述した<script>タグ(JSONP)
2. ブラウザがindex.htmlにGETリクエストを送る
3. レンダリング後bの<script>が実行されることによってsrcで指定したURIへGETリクエストが走る
4. レスポンスボディにaの関数fooを呼び出すコードが入る
5. 4のコードがブラウザで実行されることによりブラウザにalertが表示される
```
