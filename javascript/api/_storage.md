# Storage
- 特定のドメインのセッションストレージ / ローカルストレージへアクセスする機能
  - セッションストレージを操作する場合は`window.sessionStorage`を使用する
  - ローカルストレージを操作する場合は`window.localStorage`を使用する
- データは 'key': 'value' の対応づけで保存される
- データはクライアント側から操作できる

### 保存できるデータ容量
- 5MB

### 有効期限
- セッションストレージ -> ウィンドウ / タブを閉じるまで
- ローカルストレージ -> 永続的に有効

### サーバーへのデータ送信のタイミング
- データ利用時

#### Cookieとの違い
- データ量
  - Cookie -> 4KB
- 有効期限
  - Cookie -> 指定した期限まで
- データ送信のタイミング
  - Cookie -> リクエスト毎
- 純粋なJavaScriptによって扱う
  - 外部のJavaScriptコードからアクセスできる
  - Cookie -> Webサーバーが作成する

## 参照
- [Storage](https://developer.mozilla.org/ja/docs/Web/API/Storage)
- [ブラウザにデータを保存するlocalStorage（ローカルストレージ）の使い方](https://www.granfairs.com/blog/staff/local-storage-01)
- [HTML5のLocal Storageを使ってはいけない（翻訳）](https://techracho.bpsinc.jp/hachi8833/2019_10_09/80851)
