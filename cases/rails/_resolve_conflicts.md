# コンフリクト解消
## Gemfile.lock
```
$ git rebase master # Gemfile.lockでコンフリクト発生

# mainのGemfile.lockを採用し、bundle installし直す
$ git checkout --theirs Gemfile.lock
$ bundle install
$ git add Gemfile Gemfile.lock
$ git rebase --continue
```

- `$ bundle install`でコンフリクトが発生した場合は対象のgemに対して`$ bundle update xxx`する

## db/schema.rb
```
$ git rebase master # db/schema.rbでコンフリクト発生

# mainのdb/schema.rbを採用し、rails db:migrateし直す
$ git checkout --theirs db/schema.rb
$ rails db:migrate
$ git add db/schema.rb
$ git rebase --continue
```
