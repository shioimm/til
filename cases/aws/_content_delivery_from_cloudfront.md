# CloudFront経由でコンテンツを配信する
1. CloudFrontのoriginsの確認
    - 環境変数`S3_ASSET_HOST`の値をCloudFrontドメイン名とする
    - CloudFrontのコンソール画面からCloudFrontドメイン名に該当するDistributionsを探す
    - CloudFront > Distributions > 詳細画面 > OriginsからOrigin domain(S3-`バケット名`)を確認する
2. S3バケットにコンテンツを配置
    - [オブジェクトのアップロード](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide/upload-objects.html)
    - S3 -> バケット -> `バケット名`
    - 「フォルダの作成」
      - フォルダ名
      - サーバー側の暗号化: 無効
    - 「アップロード」
      - アクセス許可: 個別の ACL アクセス許可の指定コンテンツのアクセス権を設定してアップロード
        - オブジェクト所有: オブジェクト(読み込み) / オブジェクト ACL(読み込み・書き込み)
        - 全員: オブジェクト(読み込み)
3. 確認
    - `S3_ASSET_HOST/作成したフォルダ名/アップロードしたファイル名`にアクセスし、コンテンツが閲覧できることを確認
