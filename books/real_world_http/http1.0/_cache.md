# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## キャッシュ機構
- 更新日時によるキャッシュ
  - リクエストに付与された日時とサーバー上のコンテンツの日時の比較
- Expiresヘッダーによるキャッシュ
  - 現在がリクエストヘッダーに付与された有効期限日時以前であることの確認
- [Pragma: no-cache](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Pragma)(-> Cache-Control)
  - 「リクエストしたコンテンツがプロキシサーバーにキャッシュされている場合も、オリジンサーバーまでリクエストを届ける」という指示
- [ETag](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/ETag)
  - サーバーがレスポンスに付与する「ファイルに関するハッシュ値」
  - クライアントは二回め以降のリクエストで、If-None-MatchヘッダーにてETagを送信する
  - サーバーはリクエストのETagの値とレスポンスするファイルのETagを比較
- [Cache-Control](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cache-Control)
  - リクエストヘッダーとレスポンスヘッダーのキャッシュ規則を指定する
- [Vary](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Vary)
  - 同じURLでもクライアントによって返す結果が異なる理由を列挙する
    - ユーザーエージェント、言語 etc
