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
- 実データのロケーション変更タスクを追加

#### 3. DBデータ移行作業
- DBデータ移行タスクを実行

#### 4. 新しいuploaderの適用
- 対象のモデルにShrineアップローダーを`include`
- 必要箇所を修正
  - model、controller、view
  - 画像の保存前に`_derivatives!`でderivativeを作成する
- このPRをマージすることでShrineが実データをpromoteできるようになる

#### 5. 実データのロケーション変更作業
- 実データのロケーション変更タスクを実行

#### 6. 後始末
- メタデータ付与用のタスクを実行
- モデルから`CarrierwaveShrineSynchronization`のincludeを削除
- 対象のテーブルからCarrierアップローダー用のカラムを削除
