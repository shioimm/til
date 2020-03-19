# 安全なWebアプリケーションの作り方(脆弱性が生まれる原理と対策の実践) まとめ
- 徳丸浩 著

## 17 JavaScriptの問題
### DOM Based XSS
- DOM Based XSS -> JavaScripによる処理の不備が原因であるXSS
- 発生箇所: アプリケーション上でJavaScriptによりDOMに関わるメソッドを呼び出している箇所
- 影響範囲: アプリケーション全体
- 影響の種類: ユーザーのブラウザ上でのJavaScriptの実行、偽情報の表示
- 影響度合い: 中〜大
- 利用者関与の範囲: 必要 -> 罠サイトの閲覧、メール記載のURLの起動、攻撃を受けたサイトの閲覧
- 対策:
  - DOM操作の適切なAPI呼び出し
  - HTMLとして特殊な意味を持つ記号のエスケープ

#### 事例
- `innerHTML`
  - フラグメント識別子(URL末尾の`#`)によって表示を変えるアプリケーションにおいて、
    フラグメント識別子以下に`innerHTML`を渡され、
    任意のスクリプトを実行されてしまう
```
// srcが見つからずエラーが発生した時点で任意のスクリプトが実行される
http://example.com/example.html#<img src=/ onerror=任意のスクリプト>
```
- `document.write`
  - フラグメント識別子(URL末尾の`#`)以下を読み込む処理をしているアプリケーションにおいて、
    フラグメント識別子以下に`document.write`を渡され、
    任意のスクリプトを実行されてしまう
```
// フラグメント識別子以下を読み込んだ時点でdocument.writeが実行される
http://example.com/example.html#%22%3E%3C/script%3E任意のスクリプト%3C/script%3E
```
- XMLHttpRequest
  - フラグメント識別子(URL末尾の`#`)をトリガーとして
    XMLHttpRequestによりコンテンツを読み込むアプリケーションにおいて、
    フラグメント識別子以下に外部のURLを渡され、
    任意のスクリプトを実行されてしまう
```
// フラグメント識別子以下を読み込んだ時点で外部のサイトに置かれている任意のスクリプトが実行される
http://example.com/example.html#//trap.example.com
```
- jQuery
  - jQueryのセレクタを動的に生成している場合、セレクタ文字列に外部からの入力値が混ざっていると
    攻撃者によって新しいセレクタを生成されてしまう場合がある
- `location.hrf`
  - 入力されたURLを元に`location.href`でリダイレクトを行なっている場合、
    フラグメント識別子以下に任意のスクリプトを渡されると、リダイレクト処理によって
    任意のスクリプトを実行されてしまう
```
// リダイレクト処理によって任意のスクリプトが実行される
http://example.com/example.html#javascript:任意のスクリプト
```

#### 原因
- 外部から指定されたHTMLタグなどが有効になってしまう機能を用いている
  - `document.write`
  - `innerHTML`
  - `$()`など
- 外部から渡されたパラメータを`eval`の引数にわたしている
- XMLHttpRequestのURLが未検証
- `location.html`、src属性、href属性のURLが未検証

#### 対策
- 適切なDOM操作や記号のエスケープ
- 外部から渡されたパラメータを`eval`の引数に渡さない
- URLスキームをhttp/httpsに限定する
- jQueryのセレクタを動的生成しない
- 最新のライブラリを用いる
- XMLHttpRequestのURLを検証する

### Webストレージの不適切な使用
#### Webストレージとは
- JavaScriptから書き込み、読み出し、削除ができる
  - サーバーへの送信は自動的に行われない
  - localStorage -> 永続的なWebストレージ
  - sessionStorage -> ブラウザのタブを開いている間だけ有効なWebストレージ
- WebストレージはJavaScriptからのアクセスを禁止しない
  - クッキーのhttpOnlyのような設定がない
  - XSS脆弱性により漏洩する可能性がある

#### 事例
- Webストレージに機密情報を保存していた
- Webストレージに保存した情報がXSS/postMessageにより漏洩した
- Webストレージに保存した情報がXSS/postMessage経由で改ざんされた
- Webストレージを経由したDOM Based XSS

### postMessage呼び出しの不備
#### postMessageとは
- 参照: [window.postMessage](https://developer.mozilla.org/ja/docs/Web/API/Window/postMessage)
- 複数の異なるオリジンのWindowオブジェクト間で安全にクロスドメイン通信を行うためのメソッド
```javascript
targetWindow.postMessage(message, targetOrigin, [transfer]);
```

#### 事例
- ターゲットオリジンに`*`を指定しており、想定外のオリジンにメッセージを送信してしまう
- メッセージ受診時に送信元のオリジンを確認しておらず、
  想定外のオリジンから受け取ったメッセージをそのまま`innerHTML`で展開してしまう

#### 対策
- 送信時: `postMessage`メソッドの第二引数にて、ターゲットのオリジンを限定する
- 受信時: `onmessage`イベントハンドラにて、`event.origin`プロパティを検証する

### オープンリダイレクト
#### 事例
- 正規サイトで実行した処理によって発生するリダイレクト先を任意の外部サイトへ指定する
```
// リダイレクト先がフラグメント識別子以下の外部サイトに指定されてしまう
http://example.com/example.html#http://trap.example.com
```

#### 対策
- リダイレクト先のURLを固定にする
- リダイレクト先URLを直接指定せずに番号などで指定する
