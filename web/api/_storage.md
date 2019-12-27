# Strage
- 参照: [Storage](https://developer.mozilla.org/ja/docs/Web/API/Storage)
- 参照: [ブラウザにデータを保存するlocalStorage（ローカルストレージ）の使い方](https://www.granfairs.com/blog/staff/local-storage-01)
- 特定のドメインのセッションストレージ / ローカルストレージへアクセスする機能
  - セッションストレージを操作する場合は`window.sessionStrage`を使用する
  - ローカルストレージを操作する場合は`window.localStrage`を使用する
- データは 'key': 'value' の対応づけで保存される
- データはクライアント側から操作できる

#### Cookieとの違い
- データ量
  - Cookie -> 4KB
  - セッションストレージ -> 5MB
  - ローカルストレージ -> 5MB
- 有効期限
  - Cookie -> 指定した期限まで
  - セッションストレージ -> ウィンドウ / タブを閉じるまで
  - ローカルストレージ -> 永続的に有効
- データ送信のタイミング
  - Cookie -> リクエスト毎
  - セッションストレージ -> データ利用時
  - ローカルストレージ -> データ利用時
- JavaScriptからの操作が容易
