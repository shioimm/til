# ファイルオーナー
- 参照: Linuxプログラミングインターフェース 15章

## TL;DR
- 全てのファイルはUIDとGIDをファイル情報として保持し
  自身が属するユーザー・グループを一意に決定する

## 新規ファイル
- 新規ファイルのオーナーは、
  そのファイルを作成したプロセスの実効ユーザーID
- 新規ファイルのグループは、
  そのファイルを作成したプロセスの実効グループID(System V)
  または親ディレクトリのグループID(BSD)

| マウントオプション | 親ディレクトリのset-group-IDビット | 新規ファイルのグループ     |
| -                  | -                                  | -                          |
| `-o grpid`         | 影響しない                         | 親ディレクトリのグループID |
| `-o nogrpid        | セットされていない                 | プロセスの実効グループID   |
| `-o nogrpid        | セットされている                   | 親ディレクトリのグループID |

## 既存ファイルのオーナー変更
- `chown(2)` / `fchown(2)` / `lchown(2)`によってファイルのオーナー・グループを変更できる
- 特権プロセスはすべてのファイルのオーナー・グループを任意に変更可能
- 非特権プロセスは自身が所有するファイルのグループIDを、自身がメンバであるグループIDへ変更可能
- オーナー・グループが変更されるとset-IDビットはクリアされる
