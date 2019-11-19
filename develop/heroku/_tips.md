### app.json
- Herokuの環境構成ファイル
- 参照: [Introducing the app.json Application Manifest](https://blog.heroku.com/introducing_the_app_json_application_manifest)

### 本番環境でログを監視する
- `heroku logs -t --app アプリ名`に対して`| grep 自分のIP`をつけることによって
動作検証時のログを監視することができる
- 自分のIPはログを出力した際に表示される`fwd="hoge.fuga.moge.moga"`
- 使い所
  - rails_adminでの操作時
