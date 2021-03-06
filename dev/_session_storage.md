# セッションストレージ
- セッションに関連してアクセスしてきたユーザーに属する情報を保存するための仕組み

## 方式
### Cookie
#### 保存場所
- ブラウザのCookie

#### 利点
- サービス間で持ち回ることができる
- サーバー側でストレージを用意する必要がない

#### 欠点
- 容量制限がある
- サーバー側でセッションクリアできない

### DB(RDB、NoSQL、Memcached)
#### 保存場所
- ブラウザのCookie(サーバーからIDのみが渡される)
- サーバー側のDB(IDから導出される鍵の情報を格納する)

#### 利点
- 容量制限がない
- サーバー側でセッションクリアできる

#### 欠点
- サーバー側でストレージを用意する必要がある
- DBアクセスが発生する

### ローカルホストのメモリ
#### 保存場所
- ブラウザのCookie(サーバーからIDのみが渡される)
- サーバーのメモリ(IDから導出される鍵の情報を格納する)

#### 利点
- 容量制限がない
- サーバー側でセッションクリアできる
- サーバー側でストレージを用意する必要がない

#### 欠点
- ローカルテスト環境用
- サーバーを再起動すると消える

## 参照
- Real World HTTP 第2版
