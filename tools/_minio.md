# MinIO
## S3の開発環境用モックとして利用する場合、導入時にやること
#### MinIOの準備
- ローカルにminioサーバーを立てる

```yml
version: '3.9'

services:
  minio:
    image: minio/minio
    environment:
      MINIO_ROOT_USER     # 環境変数で管理
      MINIO_ROOT_PASSWORD # 環境変数で管理
    command: "server --console-address :9001 /data"
    ports:
      - 9000:9000
      - 9001:9001
    volumes:
      - ./data/minio:/data:delegate
```

- minioコンソール (`localhost:9001`) にログイン、バケットを作成し、任意のパスにデータを置く

#### クライアントの準備 (S3)

```ruby
module S3ClientInitializer
  class Production
    def s3client
      Aws::S3::Client.new(
        region:            ...,
        access_key_id:     ...,
        secret_access_key: ...,
      )
    end
  end

  class Development
    def s3client
      Aws::S3::Client.new(
        endpoint:          "http://localhost:9001/",
        access_key_id:     ENV['MINIO_ROOT_USER'],
        secret_access_key: ENV['MINIO_ROOT_PASSWORD']
      )
    end
  end
end
```

```ruby
# config/environments/production.rb

Rails.application.configure do
  config.x.s3_client_initializer = S3ClientInitializer::Production.new
  ...
end

# config/environments/test.rb / config/environments/development.rb

Rails.application.configure do
  config.x.s3_client_initializer = S3ClientInitializer::Development.new
  ...
end
```
