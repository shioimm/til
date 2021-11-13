# Turbo Drive
- Turbolinksを改善したライブラリ
- レスポンスのHTMLのうちの一部を使って、元のHTMLのうち`<body>`タグの中身を全て差し替える

#### 処理
- リンクやフォーム送信 (Web標準で遷移が発生する処理) にフックし、
  -> JavaScriptでfetch
  -> レスポンスのHTMLから`<head>`内を処理
  -> `<body>`を新しいものにすり替え
  -> History APIでlocationを更新する

#### Turbolinksからの改善点
- formに対応
  - `form_with`ヘルパーからデフォルトの`data-remote="true"`をオフ
  - 300番台のレスポンス時はリダイレクト
  - 400・500番台のレスポンス時はボディタグの中身を差し替えてページ履歴は変更しない

#### 弱点
- ページ内の一部のみの更新ができない

## 参照
- [クライアント側のJavaScriptを最小限にするHotwire](https://logmi.jp/tech/articles/324219)
- [Hotwireとは何なのか？](https://zenn.dev/en30/articles/2e8e0c55c128e0)
