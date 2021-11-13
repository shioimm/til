# ActiveStorage
- Railsが標準で提供する画像アップロード機能

#### サポートしている画像変換用プロセッサ
- ImageMagick
- GraphicsMagick
- lipvips

#### 課題
- 公式のvalidationヘルパーがバンドルされていない
  - gem `active_storage_validation`などを使用する
- cacheの不足
  - バリデーションでフォームに戻った際、画像を添付し直す必要がある

### 関連モデル
#### `ActiveStorage::Blob`モデル
- アップロードファイルのメタ情報を扱う
- `ActiveStorage::Blob has_many Attachments`

#### `ActiveStorage::Attachment`モデル
- ActiveStorageを使用するXxxモデルとActiveStorage::Blobモデルの中間テーブル
- `Xxx has_many ActiveStorage::Attachments`

#### ActiveStorageを使用するXxxモデル
- ポリモーフィック関連によって画像を扱う
- `Xxx has_one_acctached :画像用カラム`
  - `Xxx has_many_acctached :画像用カラム`
- XxxとActiveStorage::Blobは一対一で関連づけられる

```ruby
class Xxx < ApplicationRecord
  has_one_attached :画像用カラム
  # has_many_acctached :画像用カラム でもOK
end
```

- `dependent: false` - 削除時、関連する`ActiveStorage::Attachment`のみ削除される
  - 1. `ActiveStorage::Attachment`削除
  - 2. `ActiveStorage::PurgeJob`(非同期処理)実行
  - 3. 非同期処理の中で`ActiveStorage::Blob`や画像を削除

## 参照
- Ruby on Rails 6エンジニア養成読本 押さえておきたい！Rails 6で改善された機能一覧
- パーフェクトRuby on Rails[増補改訂版] P225-234 / 384 / 386
