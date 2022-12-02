# pg gemのインストール時に特定のバージョンの`pg_config`へのパスを指定する

```
$ where postgres
/opt/homebrew/opt/postgresql@13/bin/postgres
/opt/homebrew/bin/postgres

$ bundle config build.pg --with-pg-config=/opt/homebrew/opt/postgresql@13/bin/postgres
$ bundle install # (bundle pristine)
```
