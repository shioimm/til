# `find(1)`
- ファイル探索
```
$ find パス -type ファイルタイプ -name ファイル名
```

```
// カレントディレクトリ以下でYYYYMMDD以降に作成された.rbファイルを探索 (macOS)

$ find ./ -name *.rb -newerBt 'YYYYMMDD'
```

- B - 作成日時
- m - 更新日時
- a - アクセス日時
- c - ステータス (inode) 変更日時
- t - 日付

```
// 特定のディレクトリを除いて.rbファイルを探索

$ find . -not -path "./src/*" -type f -name *.rb
```
