# Upgrading from CarrierWave
- [Upgrading from CarrierWave](https://shrinerb.com/docs/carrierwave)
- [Getting Started](https://shrinerb.com/docs/getting-started)

## 手順
1. uploaderの追加・二重書き込みの開始
    - 新しいuploaderを追加
    - `CarrierwaveShrineSynchronization`モジュールを追加
    - テーブルに`COLUMN_NAME_data`カラムを追加
    - モデルに`CarrierwaveShrineSynchronization`をinclude
2. データ移行準備
    - データ移行用のタスクを追加
    - メタデータ付与用のタスクを追加
2. データ移行作業
    - データ移行タスクを実行
3. 新しいuploaderの適用
    - モデルに新しいuploaderを`include`して必要箇所を修正
    - 必要があれば画像の保存前に`_derivatives!`でderivativeを作成する
4. 後始末
    - モデルから`CarrierwaveShrineSynchronization`のincludeを削除
    - テーブルから`COLUMN_NAME_data`カラムを削除
