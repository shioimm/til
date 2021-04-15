# OpenAPI
- 参照: [OpenAPI Specification](https://swagger.io/specification/)
- 参照: [OpenAPI の概要](https://cloud.google.com/endpoints/docs/openapi/openapi-overview?hl=ja)
- RESTful APIにおけるインターフェイス定義の記述形式
  - OAS: OpenAPI仕様
- Swaggerが標準的実装となっている

### 用途
- APIを表示するドキュメント生成ツール
- 多様なプログラミング言語でサーバーやクライアントを生成するコード生成ツール
- テストツール など

### OpenAPIによって定義されるもの
- APIの名前と説明
- API内の個々のエンドポイント
- 呼び出し元の認証方法

### 仕様
- インターフェイス定義はJSONもしくはYAMLによって記述される

### Swagger
- OASによるAPI仕様を書くためのツール
  - [Swagger Editor](https://swagger.io/tools/swagger-editor/)
    - OpenAPIベースのAPIに特化したオープンソースエディタ
  - [Swagger UI](https://swagger.io/tools/swagger-ui/)
    - ドキュメント生成ツール
    - OASから自動的にAPIリソースを視覚化する
  - [Swagger Codegen](https://swagger.io/tools/swagger-codegen/)
    - コード生成ツール
    - OASで定義されたAPI用サーバースタブとクライアントSDKを生成する
