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
