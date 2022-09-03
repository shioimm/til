# OpenAPI
#### 定義ファイルをエディタで作成
- [Swagger Editor](https://swagger.io/tools/swagger-editor/)

#### 定義ファイルをコードから作成
- [FastAPI](https://fastapi.tiangolo.com/ja/) (Python)
- [rspec-openapi](https://github.com/k0kubun/rspec-openapi) (Ruby)

#### 定義ファイルを読み込んでドキュメントとして可視化
- [Swagger UI](https://swagger.io/tools/swagger-ui/)
- [Swagger Codegen](https://swagger.io/tools/swagger-codegen/)
  - コード生成ツール
  - OASで定義されたAPI用サーバースタブとクライアントSDKを生成する

#### ソースコードの自動生成
- [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator)
  - 定義ファイルからリクエスト / レスポンスのインターフェースと
    APIを呼び出すフロントエンドコードを生成
- [oapi-codegen](https://github.com/deepmap/oapi-codegen)
  - 定義ファイルからリクエスト / レスポンスに対応した構造体や
    リクエストハンドラとしてのインターフェースとなるバックエンドコードを生成

#### 定義ファイルの型やサンプル入出力を利用してモックサーバを作成
- [Prisma](https://github.com/stoplightio/prism)

#### 実際のリクエスト・レスポンス時の値と定義ファイルが一致しているかを確認
- [committee](https://github.com/interagent/committee)

#### 分割された定義ファイルの統合
- [swagger-cli](https://github.com/APIDevTools/swagger-cli)
