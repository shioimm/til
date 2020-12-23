# クエリ
- 参照: [GraphQL](https://graphql.org/)
- 参照: 初めてのGraphQL 3章

## TL;DR
- GraphQLにおけるクエリは問い合わせ(`query`)と変更(`mutation`)の二種類
- GraphQLは全てのHTTPリクエストをPOSTリクエストとして発行する
- GraphQLはクエリをPOSTリクエストのbodyとして使用する

```
query {
  user {
    name
  }
}

# 上記のクエリは以下のHTTPリクエストに等しい
#   $ curl 'http://example.com/' \
#           -H 'Content-Type: application/json' \
#           --data '{"query":"{ allLifts { name }}"}'

mutation {
  setUserStatus(id: 1, status: OK) {
    name
    status
  }
}

# 上記のクエリは以下のHTTPリクエストに等しい
#   $ curl 'http://snowtooth.herokuapp.com/' \
#          -H 'Content-Type: application/json' \
#          --data '{"query":"mutation {setUserStatus(id: \"1\" status:OK) {name status}}"}'
```

- GraphQLサーバーはリクエストが指定したJSONを返す
  - 正常系 -> dataキーに返り値を与える
  - 異常系 -> errorキーに返り値を与える

## 文法
- ルート型 - `query` / `mutation`
- 選択セット - `{ }`で囲まれたブロック
- フィールド - 処理名

```
ルート型 フィールド {
  取得したいデータ
}
```

- クエリドキュメントトップレベルには複数のクエリを書ける
- 一回で実行できるのは一クエリのみ

```
ルート型 フィールド1 {
  取得したいデータ
}

ルート型 フィールド2 {
  取得したいデータ
}
```

- 複数のクエリを同時に実行するためにはトップレベルの一クエリの中で複数のクエリを書く必要がある

```
ルート型 フィールド0 {
  フィールド1 {
    取得したいデータ
  }

  フィールド2 {
    取得したいデータ
  }
}
```

- レスポンスのキーをエイリアスとして指定可能
- クエリ引数を与えることが可能
- idを指定しレコードの特定を行うことが可能
```
ルート型 フィールド0 {
  エイリアス1: フィールド1(引数名: クエリ引数)
  エイリアス2: フィールド2 {
    エイリアスA: 取得したいデータ
    取得したいデータ
  }
  フィールド3(id: IDの指定) {
    取得したいデータ
  }
}
```
