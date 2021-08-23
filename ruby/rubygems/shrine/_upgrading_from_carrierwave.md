# Upgrading from CarrierWave
- [Upgrading from CarrierWave](https://shrinerb.com/docs/carrierwave)
- [Getting Started](https://shrinerb.com/docs/getting-started)
- [Migrating File Locations: 2. Move existing files](https://shrinerb.com/docs/changing-location#2-move-existing-files)

## 手順
#### 1. Shrineアップローダーの追加・二重書き込みの開始
- Shrineアップローダーを追加
- `CarrierwaveShrineSynchronization`モジュールを追加
  - `location`(実データのアップロード先)はCarrierWaveと同じにする
- 対象のモデルに`CarrierwaveShrineSynchronization`をinclude
- 対象のテーブルにShrineアップローダー用のカラムを追加

#### 2. データ移行準備
- DBデータ移行タスクを追加
- メタデータ付与タスクを追加

#### 3. DBデータ移行作業
- DBデータ移行タスクを実行 - Shrineアップローダー用のカラムに値が入る
  - Shrineが参照するパスとCarrierWaveが実際にデータをアップロードしているパスが異なる可能性があり、
    その場合はShrineの参照先に実データをコピーしないと、切り替え時に`Shrine::FileNotFound`が発生する
  - [オブジェクトのコピー](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-copy)

#### 4. アップローダーの切り替え
- 対象のモデルにShrineアップローダーを`include`
- 必要箇所を修正
  - model、controller、view
  - 画像の保存前に`_derivatives!`でderivativeを作成する
- このPRをマージすることでShrineが実データをpromoteできるようになる

#### 5. メタデータ付与作業
- メタデータ付与用のタスクを実行

#### 6. 後始末
- モデルから`CarrierwaveShrineSynchronization`のincludeを削除
- 対象のテーブルからCarrierWaveアップローダー用のカラムを削除
