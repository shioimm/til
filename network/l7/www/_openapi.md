# OpenAPI
- プログラミング言語に依存しないHTTP APIのインターフェース仕様を記述するための仕様
  - OAS: OpenAPI仕様
- 各エンドポイントに対して説明、リクエスト / レスポンスの構造、型などの情報を定義する
- インターフェイス定義はJSONもしくはYAMLによって記述される

#### OpenAPIの活用例
- 読みやすいドキュメントの生成
- リクエスト / レスポンスのバリデーション
- クライアントライブラリの生成
- モックサーバーの生成

## 基本構造 (OpenAPI 3.0系)
- Info (必須) (定義ファイル自体のメタデータの定義)
 - Pathes (必須) (各エンドポイントと対応する仕様の定義)
  - Path Item (各エンドポイント)
    - Operation (パラメータやリクエストボディ、レスポンスの形式)
      - Parameter (パス、クエリ、ヘッダ)
        - Schema (リクエストするパラメータの形式)
- Server (サーバのURLなど)
- Components (再利用可能な参照用のオブジェクト)
- Security
- Tags
- ExternalDocs

## 参照
- [OpenAPI Specification](https://swagger.io/specification/)
- [OpenAPI の概要](https://cloud.google.com/endpoints/docs/openapi/openapi-overview?hl=ja)
- Software Design 2022年8月号
