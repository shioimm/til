# credentials.yml.enc
- 参照: Ruby on Rails 6エンジニア養成読本 押さえておきたい！Rails 6で改善された機能一覧
- アプリケーション開発において、秘密情報を管理するためのファイル
  - 内容は暗号化されている
  - 本番環境で使用する情報がcredentialsの管理の対象となる
    - 開発環境で使用するものは秘匿する必要がないため
    - 本番環境以外の情報を秘匿する場合は
    コマンド実行時にオプション`--environment staging(or ...)`をつける

### `master.key` or `ENV[RAILS_MASTER_KEY]`
- 暗号化・複合化のために使用するキー

## credentials.yml.encを編集する
```sh
$ rails credentials:edit
```

### `credentials.yml.enc`が存在しない場合
- `$ rails credentials:edit`を実行すると`config/`配下に新たに`credentials.yml.enc`が追加される
- 同時に`config/master.key`が生成され、`.gitignore`に`/config/master.key`が追記される(Rails 6.0~)

## credentials.yml.encを編集する
```sh
$ rails credentials:show
```
