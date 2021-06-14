# 画像アップロード機能のテストデータ
#### Rack::Test::UploadedFileを利用する
```ruby
let(:image_src) {
  Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/image.png'))
}
```

#### Shrineを利用する
- [Testing with Shrine](https://shrinerb.com/docs/testing)

```ruby
module ShrineData
  module_function

  def image_data
    attacher = Shrine::Attacher.new
    attacher.set(uploaded_image)

    # if you're processing derivatives
    attacher.set_derivatives(
      large: uploaded_image,
      medium: uploaded_image,
      small: uploaded_image,
    )

    attacher.column_data # or attacher.data in case of postgres jsonb column
  end

  def uploaded_image
    file = File.open(Rails.root.join('spec/fixtures/files/image.png'), binmode: true)

    # for performance we skip metadata extraction and assign test metadata
    uploaded_file = Shrine.upload(file, :store, metadata: false)
    uploaded_file.metadata.merge!(
      "size" => File.size(file.path),
      "mime_type" => "image/png",
      "filename" => "サンプル画像データ.png"
    )

    uploaded_file
  end

  def cached_data
    file = File.open(Rails.root.join('spec/fixtures/files/image.png'), binmode: true)
    cached = Shrine.upload(file, :cache)
    cached.to_json
  end
end
```

```ruby
let(:image_src) { Shrine.image_data }
```
