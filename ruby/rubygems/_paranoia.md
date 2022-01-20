# paranoia

| メソッド               | 処理内容                                    |
| -                      | -                                           |
| `#destroy` / `#delete` | 論理削除 (`deleted_at`タイムスタンプの追加) |
| `#really_destroy!`     | 物理削除                                    |
| `#deleted?`            | 論理削除済みかどうか確認                    |
| `#restore`             | 論理削除の取り消し                          |
| `.with_deleted`        | 論理削除済みのレコードを含めて取得          |
| `.only_deleted`        | 論理削除済みのレコードのみ取得              |

- `#really_destroy!`すると関連するすべての`dependent: :destroy`レコードも物理削除される

## 参照
- [rubysherpas/paranoia](https://github.com/rubysherpas/paranoia)
