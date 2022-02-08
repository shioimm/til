# `has_one`
- 新しいオブジェクトのbuildで古いオブジェクトがdestroyされる

```ruby
[1] pry(main)> current_use.build_profile(name: 'name').save
  User Load (0.5ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT $1  [["LIMIT", 1]]
  Profile Load (0.5ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."user_id" = $1 LIMIT $2  [["user_id", 42], ["LIMIT", 1]]
   (0.2ms)  BEGIN
  Profile Create (0.8ms)  INSERT INTO "profiles" ("name", "user_id", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "name"], ["user_id", 42], ["created_at", "2020-06-09 14:41:26.772362"], ["updated_at", "2020-06-09 14:41:26.772362"]]
   (0.6ms)  COMMIT
=> true
[2] pry(main)> current_user.build_profile(name: 'profile').save
  User Load (0.6ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT $1  [["LIMIT", 1]]
  Profile Load (0.4ms)  SELECT "profiles".* FROM "profiles" WHERE "profiles"."user_id" = $1 LIMIT $2  [["user_id", 42], ["LIMIT", 1]]
   (0.3ms)  BEGIN
  Profile Destroy (0.5ms)  DELETE FROM "profiles" WHERE "profiles"."id" = $1  [["id", 21]]
   (0.4ms)  COMMIT
   (0.1ms)  BEGIN
  Profile Create (0.4ms)  INSERT INTO "profiles" ("name", "user_id", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "profile"], ["user_id", 42], ["created_at", "2020-06-09 14:41:38.683070"], ["updated_at", "2020-06-09 14:41:38.683070"]]
   (0.3ms)  COMMIT
=> true
```

- `build_association`を使用すると発生する
- 代わりに`new`や`find_or_initialize_by`を使用する

#### `autosave: true`
- 関連先のレコードが存在する場合でも上書きする
