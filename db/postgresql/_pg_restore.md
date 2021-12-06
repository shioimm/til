# `pg_restore`
- [`pg_dump`](https://www.postgresql.jp/document/12/html/app-pgdump.html)

```
$ pg_restore --verbose --data-only --no-owner --no-acl --disable-triggers -h localhost -d xxxx_development -U username -p 5432 ../DUMPFILE_NAME.dump
```

- `--verbose` - 冗長モード
- `--data-only` - スキーマをダンプせずデータのみダンプ
- `--no-owner` - オブジェクトの所有権を元のデータベースにマッチさせるためのコマンドを出力しない
- `--no-acl` - アクセス権限のダンプを抑制
- `--disable-triggers` - データの再ロード中に対象テーブル上のトリガを一時的に無効にする
- `-h` - サーバーが稼働しているマシンのホスト名
- `-d` - 接続するデータベースの名前
- `-U` - 接続ユーザー名
- `-p` - サーバーが接続を監視するTCPポート番号
