# テスト環境のDB
#### DBリセット

```
$ bin/rails db:environment:set RAILS_ENV=test
$ bin/rails db:migrate:reset RAILS_ENV=test

# または
# $ bin/rails db:drop RAILS_ENV=test
# $ bin/rails db:create RAILS_ENV=test
# $ bin/rails db:migrate RAILS_ENV=test
```

#### テスト環境のDBにアクセスする

```
# Railsコンソール
$ rails c -e test

# DBコンソール
$ rails dbconsole -e test
```

#### `PG::UndefinedObject: ERROR:  type "geometry" does not exist`

```
$ rails dbconsole -e test
psql (14.7 (Homebrew), server 11.17)
Type "help" for help.

hyrule_test=# CREATE EXTENSION postgis;
CREATE EXTENSION
```
