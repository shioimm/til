# Gitによる運用

```
# 既存のアプリケーションに対してGitリモートを作成する場合
$ heroku git:remote --remote <App Name> -a <App Name>

# 新しくreview appを作る場合 (App Name == Remote Name)
$ heroku apps:create <App Name> -r <App Name>
$ git push <App Name> main

# デプロイ時
$ git push <App Name> main

# ブランチで変更を適用する場合
# 1. CIが通るのを待つ
# 2. review appにpush
$ git checkoout <Branch Name>
$ git push <App Name (review app)> main
# 3. review appで動作確認

# mainにマージした場合
# 1. mainのCIが通るのを待つ
# 2. ステージングにpush
$ git checkoout main
$ git pull origin main
$ git push <App Name (ステージング)> main
# 3. ステージングで動作確認
# 4. 本番にpush
$ git push <App Name (本番)> main
# 5. 本番で動作確認
```
