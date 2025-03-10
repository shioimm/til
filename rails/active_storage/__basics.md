# ActiveStorage
- Railsが標準で提供する画像アップロード機能

#### サポートしている画像変換用プロセッサ
- lipvips (またはImageMagick) (画像解析や画像変形用)
- ffmpeg (動画プレビュー、ffprobeによる動画/音声解析用)
- poppler / muPDF (PDFプレビュー用)

#### 注意
- ActiveRecordのバリデーションが適用されない
  - gem `active_storage_validation`などを使用する
    - ファイルの存在チェックや拡張子、サイズ制限のバリデーションを行う
- フォーム送信時のキャッシュ不足
  - バリデーションエラーでフォームに戻った際、添付した画像が再アップロードされない
  - ダイレクトアップロードによってページリロード後もファイルを保持できる
    - `direct_upload: true`を利用してJS経由でファイルをアップロードし、BlobのIDを`hidden_field`に埋め込む

## 関連テーブル
#### `active_storage_blobs`
- アップロードファイルのメタ情報を保存する
  - `ActiveStorage::Blob has_many Attachments`

### `active_storage_attachments`
- ActiveStorageを使用するFooモデルとActiveStorage::Blobモデルの中間テーブル
  - 1つの`Foo`レコードが複数の添付ファイルを持つ場合 (`has_many_attached`) に使用される
  - `Foo has_many ActiveStorage::Attachments`

### `active_storage_variant_records`
- バリアントトラッキングが有効な場合は、生成された各バリアントに関するレコードを保存する

### ActiveStorageを使用するモデルのテーブル
- ポリモーフィック関連によって画像を扱う
- `Foo has_one_attached :avatar`
  - `Foo has_many_attached :avatar`
- FooとActiveStorage::Blobは一対一で関連づけられる

```ruby
class Foo < ApplicationRecord
  has_one_attached :avatar # または has_many_attached :avatar
end
```

#### 削除時
- `dependent: false` - 削除時、関連する`ActiveStorage::Attachment`のみ削除される
- デフォルトでは、`ActiveStorage::Blob` の削除は非同期 (`PurgeJob`) で行われる
  - 1. `ActiveStorage::Attachment`削除
  - 2. `ActiveStorage::PurgeJob`(非同期処理)実行
  - 3. 非同期処理の中で`ActiveStorage::Blob`や画像を削除
- `dependent: :purge_later` を指定すると、`ActiveStorage::Blob` は非同期で削除される
- `dependent: :purge` を指定すると、即座に削除される
- `dependent: false` の場合、`ActiveStorage::Attachment` のみ削除され、Blob は残る

## 参照
- Ruby on Rails 6エンジニア養成読本 押さえておきたい！Rails 6で改善された機能一覧
- パーフェクトRuby on Rails[増補改訂版] P225-234 / 384 / 386
