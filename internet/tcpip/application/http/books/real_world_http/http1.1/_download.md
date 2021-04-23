# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## ダウンロード
- レスポンスヘッダーに[Content-Disposition](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Disposition)が含まれる場合、ブラウザは保存ダイアログを出しデータを保存する
- ダウンロードの中断が中断された場合、途中から再開する方法が提供されている
  - 途中から再開 = ファイルの指定範囲を切り出してダウンロードする
  - 指定範囲ダウンロードをサポートしているサーバーは次のヘッダーをレスポンスに付与する
    - [Accept-Ranges](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Accept-Ranges)ヘッダーをレスポンスに付与する
    - [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag) -> コンテンツの変更を検知するため
  - ブラウザは[Range](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Range)ヘッダーをリクエストに与えて転送してほしい範囲を指定する
    - Rangeヘッダーは複数範囲の指定も可能
      - サーバーは`Content-Type: multipart/byteranges;`を返す
      - ダウンロード時間短縮のためRangeヘッダーを使用し並列ダウンロードを行うことは、サーバーに負荷をかけるため推奨されていない
