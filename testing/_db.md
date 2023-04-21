# テスト環境のDBのリセット

```
$ bin/rails db:environment:set RAILS_ENV=test
$ bin/rails db:migrate:reset RAILS_ENV=test

# または
# $ bin/rails db:drop RAILS_ENV=test
# $ bin/rails db:create RAILS_ENV=test
# $ bin/rails db:migrate RAILS_ENV=test
```
