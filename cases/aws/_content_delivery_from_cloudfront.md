# CloudFront経由でコンテンツを配信する
1. CloudFrontのoriginsの確認
    - 環境変数`S3_ASSET_HOST`の値をCloudFrontドメイン名とする
    - CloudFrontのコンソール画面からCloudFrontドメイン名に該当するDistributionsを探す
    - CloudFront > Distributions > 詳細画面 > OriginからOrigin domain(S3のバケット名)を確認する
2. S3バケットにコンテンツを配置
    - S3 > バケット > バケット名へ移動
    - コンテンツを置くためのフォルダを作成 > アップロード
    - コンテンツのアクセス権を設定してアップロード
    - `個別のACLアクセス許可の指定` / `全員(パブリックアクセス): 読み込み可`
3. 確認
    - `S3_ASSET_HOST`/フォルダ名/ファイル名にアクセスし、コンテンツが保存されていることを確認
