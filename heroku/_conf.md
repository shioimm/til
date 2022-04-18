# 環境
## Stack
- [Stacks (operating system images)](https://devcenter.heroku.com/categories/stacks)
- Heroku環境のOSイメージ(Ubuntuベース)

#### Stackのアップデート
- app.jsonにて`"stack": "heroku-番号"`を記述
- review appsにて動作確認後、マージ

## Buildpacks
- [Buildpacks](https://devcenter.heroku.com/articles/buildpacks)
- 個別のランタイムパッケージ

## app.json
- [Introducing the app.json Application Manifest](https://blog.heroku.com/introducing_the_app_json_application_manifest)
- Herokuの環境構成ファイル
