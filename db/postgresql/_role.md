# role
#### ユーザーのロールを変更する

```sql
alter role <UserName> with superuser createdb
-- -> 対象のユーザーにスーパーユーザー権限を与える
```

- `<UserName>` - Railsの場合はdatabase.yaml指定のusername

## 参照
- [PostgreSQL 11.5文書 SQLコマンド ALTER ROLE](https://www.postgresql.jp/document/11/html/sql-alterrole.html)
