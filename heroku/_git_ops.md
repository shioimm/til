# Gitによる運用
```
# 既存のアプリケーションに対してHerokuリモートを作成する場合
$ heroku git:remote -a <App Name>

# 新しくreview appを作る場合
$ heroku create --remote <App Name>
$ git push <App Name> main

# デプロイ時
$ git push <App Name> main
```
