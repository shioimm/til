# GraphQL
- 参照: [「GraphQL」徹底入門 ─ RESTとの比較、API・フロント双方の実装から学ぶ](https://employment.en-japan.com/engineerhub/entry/2018/12/26/103000)
- Facebookによって開発されたWeb APIのための言語仕様
  - クエリ言語 + スキーマ言語
  - リクエストクエリはスキーマに従ってGraphQL処理系により実行されレスポンスを生成する

## 用語
#### クエリ言語
- GraphQL APIのリクエストのための言語
  - query -> データ取得系
  - mutation -> データ更新系
  - subscription -> サーバーサイドからのイベント通知

#### スキーマ言語
- GraphQL APIの仕様を記述するための言語

#### GraphiQL
- GraphQLのための開発環境
- クエリの結果を見るために使用する

## 特徴
- クエリの構造とレスポンスの構造が対応関係にある
- スキーマベースのWeb API規格である
- エンドポイントが一つに集約されている
- POSTリクエスト
