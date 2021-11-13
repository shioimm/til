# Turbo Frames
- Turbo Driveよりも部分的な最適化に特化したライブラリ
- レスポンスのHTMLのうちの一部を使って、元のHTMLのうち一部を部分的に差し替える

#### Turbo Driveへの補完
- ページ内の部分的な更新を行う
- ページ内の一部分を遅延読み込みする

#### 弱点
- リンク、フォーム送信をフックする以外にDOM操作をする方法がない
- 複数フレームの同時更新ができない

## 参照
- [クライアント側のJavaScriptを最小限にするHotwire](https://logmi.jp/tech/articles/324219)
- [まるでフロントエンドの"Rails" Hotwireを使ってJavaScriptの量を最低限に](https://logmi.jp/tech/articles/324253)
- [Hotwireとは何なのか？](https://zenn.dev/en30/articles/2e8e0c55c128e0)
