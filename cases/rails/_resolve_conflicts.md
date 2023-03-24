# コンフリクト解消
## Gemfile.lock
```
$ git rebase main # Gemfile.lockでコンフリクト発生

# mainのGemfile.lockを採用し、bundle installし直す
$ git checkout --theirs Gemfile.lock
$ bundle install
$ git add Gemfile Gemfile.lock
$ git rebase --continue
```

- `$ bundle install`でコンフリクトが発生した場合は対象のgemに対して`$ bundle update xxx`する

## db/schema.rb
```
$ git rebase main # db/schema.rbでコンフリクト発生

# mainのdb/schema.rbを採用し、rails db:migrateし直す
$ git checkout --theirs db/schema.rb
$ rails db:migrate
$ git add db/schema.rb
$ git rebase --continue
```

### スキーマのコンフリクトを解消した後、migrateできない
- 対象のバージョン番号のマイグレーションの状態が`down`になっている場合、
  `schema_migration`テーブルにバージョン番号を示すレコードが存在しない状態になっている

```
$ rails db
# select * from schema_migrations where version = '<対象のマイグレーションバージョン番号>';
# insert into schema_migrations(version) values (<対象のマイグレーションバージョン番号>);
# select * from schema_migrations where version = '<対象のマイグレーションバージョン番号>';
```
