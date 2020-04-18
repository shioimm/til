#ActiveRecord::QueryMethods
## where
- Time型・Date型のカラムは文字列で検索することができる
```
pry(main)> Lesson.where(starts_at: "13:00:00")
   (0.9ms)  SELECT COUNT(*) FROM "lessons" WHERE "lessons"."deleted_at" IS NULL AND "lessons"."starts_at" = $1  [["starts_at", "13:00:00"]]
  Lesson Load (0.7ms)  SELECT "lessons".* FROM "lessons" WHERE "lessons"."deleted_at" IS NULL AND "lessons"."starts_at" = $1  [["starts_at", "13:00:00"]]
```

```
pry(main)> Lesson.where(date: "2018 Nov 19")
   (0.7ms)  SELECT COUNT(*) FROM "lessons" WHERE "lessons"."deleted_at" IS NULL AND "lessons"."date" = $1  [["date", "2018-11-19"]]
  Lesson Load (0.6ms)  SELECT "lessons".* FROM "lessons" WHERE "lessons"."deleted_at" IS NULL AND "lessons"."date" = $1  [["date", "2018-11-19"]]
```
