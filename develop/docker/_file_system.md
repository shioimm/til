# ファイルシステム
- 参照: [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その6:Dockerのファイルシステムってどうなってるの？ 〜](https://tech-lab.sios.jp/archives/21103)

## OverlayFS
- Dockerリポジトリにおいてイメージを格納する容量を削減する目的で使用されているファイルシステム
- レイヤーを重ね合わせ、一つのディレクトリであるかのように結合して見せるファイルシステム
  - 結合時に同名のファイルが存在する場合、上位レイヤー内に存在しているファイルのみ見える
```
$ mount -t overlay [一意の識別名] -o lowerdir=[lowerdirに指定するディレクトリ],upperdir=[upperdirに指定するディレクトリ],workdir=[workdirに指定するディレクトリ] [mergeddirに指定するディレクトリ]
```

### レイヤー構造
#### `mergedir`
- `lowerdir` / `upperdir`を結合したディレクトリ
- ファイルの追加・変更・削除操作を行う

#### `upperdir`
- mergedirで追加・変更・削除されたファイルが実際に保存されるディレクトリ
  - 追加操作 -> `upperdir`にファイルが追加される
  - 変更操作 -> `lowerdir`から`upperdir`へファイルがコピーされ内容が変更される
  - 削除操作 -> `lowerdir`から`upperdir`に同名のキャラクタデバイスファイルが作成される
#### `lowerdir`
- ベースとなるディレクトリ
- 読み取り専用(変更時は再mountが必要)

#### `workdir`
- 内部的に利用される作業用ディレクトリ

## DockerにおけるOverlayFS
- Dockerfileは上から下へ読み込まれる
- Dockerfileに記載されている設定一行ごとにOverlayFSの`lowerdir`層が形成される
  - ファイルシステムに影響のないコマンドを除く
- ベースとするDockerイメージが`lowerdir`の最下層レイヤーとなる
- 最終的に形成される`mergeddir`が起動したDockerコンテナの姿となる
- Dockerコンテナ(`mergeddir`)内で追加・変更・削除されたファイルは`upperdir`に保存される
