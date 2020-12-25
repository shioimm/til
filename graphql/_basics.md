# GraphQL
- 参照: [GraphQL](https://graphql.org/)
- 参照: [「GraphQL」徹底入門 ─ RESTとの比較、API・フロント双方の実装から学ぶ](https://employment.en-japan.com/engineerhub/entry/2018/12/26/103000)
- 参照: 初めてのGraphQL 1章

## TL;DR
- APIのためのクエリ言語
- クエリの構造とレスポンスの構造が対応関係にある
- エンドポイントが一つに集約されている(`/graphql`)
- POSTリクエストによって実行される

```
# https://graphql.org/swapi-graphql/

# リクエスト
query {
  person(personID: 1) {
    name
    birthYear
  }
}

# レスポンス
{
  "data": {
    "person": {
      "name": "Luke Skywalker",
      "birthYear": "19BBY"
    }
  }
}
```

- GraphQLスキーマに則ってサーバーサイドで型が定義されている

```
# https://graphql.org/swapi-graphql/

type Person {
      id: ID!
      name: String
      birthYear: String
      eyeColor: String
      gender: String
      hairColor: String
      height: Int
      mass: Float
      skinColor: String
      homeworld: Planet
      species: Species
      filmConnection: PersonFilmsConnection
      starshipConnection: PersonStarshipConnection
      vehicleConnection: PersonVehiclesConnection
      created: String
      edited: String
}
```

## 設計原則
- [GraphQL 設計に関するガイドライン](http://spec.graphql.org/June2018/#sec-Overview)
- 階層構造
- プロダクト中心
- 強い型付け
- クライアントごとのクエリ
- 自己参照

## 統合開発環境
- ブラウザ上で利用できるGraphQL APIのための統合開発環境
- GraphiQL
  - [GitHub - graphql/graphiql: GraphiQL & the GraphQL LSP Reference Ecosystem for building browser & IDE tools.](https://github.com/graphql/graphiql)
- GraphQL Playground
  - [GraphQL Playground](https://www.graphqlbin.com/v2/new)

## GraphQLクライアント
- [Relay](https://facebook.github.io/relay/)
  - Facebookによる実装
  - ReactコンポーネントとGraphQLサーバーから取得したデータを結びつけることを目的とする
- [Apollo](https://www.apollographql.com/)
  - Meteorの開発グループが開発
  - Apolloクライアントはすべてのメジャーなフロントエンドのプラットフォームとフレームワークをサポートしている
  - バックエンドのパフォーマンス向上ツールやAPIのパフォーマンスのモニタリングツールも提供している

## 型定義の自動生成
- [GraphQL Code Generator | GraphQL Code Generator](https://graphql-code-generator.com/)
  - Typescriptのために型定義を自動生成する
