# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## WebDAV
- HTTPを拡張して同期型の分散ファイルシステムとして使用できるようにしたもの
- HTTP/1.1の時代に開発
- MSが開発
- GitでサポートされているSSH、HTTPSのうちHTTPSはWebDAVを使用している

#### 用語
- リソース -> データを格納するファイル
- プロパティ -> リソースやコレクションに追加できる情報(作成者、更新日時etc)
- ロック -> 複数人同時編集によるコンフリクトを防ぐ仕組み

#### 独自に追加されたメソッド
- COPY -> 追加されたメソッド
- MOVE -> 追加されたメソッド
- MKCOL -> 追加されたメソッド / コレクションを作成する
- PROPFIND -> 追加されたメソッド / コレクション内の要素一覧を取得する
- UNLOCK -> 追加されたメソッド / ロックを制御する
