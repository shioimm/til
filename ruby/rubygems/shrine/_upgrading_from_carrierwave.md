# Upgrading from CarrierWave
- [Upgrading from CarrierWave](https://shrinerb.com/docs/carrierwave)
- [Getting Started](https://shrinerb.com/docs/getting-started)
- [Migrating File Locations: 2. Move existing files](https://shrinerb.com/docs/changing-location#2-move-existing-files)

## 手順
#### 1. Shrineアップローダーの追加・二重書き込みの開始
- Shrineアップローダーを追加
- `CarrierwaveShrineSynchronization`モジュールを追加
  - `location`(オブジェクトのアップロード先)はCarrierWaveと同じにする
- 対象のモデルに`CarrierwaveShrineSynchronization`をinclude
- 対象のテーブルにShrineアップローダー用のカラムを追加

#### 2. データ移行準備
- DBデータ移行タスクを追加 - Shrineアップローダー用のカラムに値を入れる
- メタデータ更新タスクを追加 - Shrineアップローダーの設定に応じてメタデータを書き換える

#### 3. データ移行作業
- DBデータ移行タスクを実行
  - CarrierWaveが実際にデータをアップロードしているパス(`uploads/`以下)と
    Shrineがデータを参照するパス(`store/`以下)が異なる可能性があり、
    その場合はShrineの参照する先にS3バケット内のオブジェクトをコピーする必要がある
    - [オブジェクトのコピー](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-copy)
    - `$ aws s3 cp s3://APPNAME/uploads/DIRNAME s3://APPNAME/store/uploads/DIRNAME/ --recursive --profile PROFILE --acl public-read`
- メタデータ更新用のタスクを実行
  - 上記の参照先パスの相違を解消していないと`refresh_metadata!`呼び出し時に`Shrine::FileNotFound`が発生する

#### 4. アップローダーの切り替え
- 対象のモデルにShrineアップローダーを`include`
- 必要箇所を修正
  - model、controller、view
  - 画像の保存前に`_derivatives!`でderivativeを作成する
- このPRをマージすることでShrineが実データをpromoteできるようになる
- モデルから`CarrierwaveShrineSynchronization`のincludeを削除

#### 5. 後始末
- 対象のテーブルからCarrierWaveアップローダー用のカラムを削除

### 実際の手順
1. Shrineアップローダーの追加適用・データ移行タスク追加PR
    - 開発環境に本番データをリストア・DBカラム移行タスク実行
    - ステージング環境に本番データをリストア・DBカラム移行タスク実行
    - 本番環境でDBカラム移行タスク実行
2. アップローダーの切り替えPR
    - ステージング環境でオブジェクト移行コマンド実行・動作確認・メタデータ移行タスクを実行
    - 本番環境でオブジェクト移行コマンド実行・動作確認・メタデータ移行タスクを実行
