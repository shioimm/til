# `dependent`
- 参照: [dependent: `:restrict_with_error` と `:restrict_with_exception` の違い](https://qiita.com/jnchito/items/3456ce734ef41d216ecd)
- 子レコードごと消したい
  - `:destroy`
  - `:delete_all`
    - DBを直接操作し、コールバックを発生させない

- 子レコードはそのまま残し、外部キーをNULLにしたい
  - :nullify

- 子レコードが存在する親レコードの削除を引き止めたい
  - `:restrict_with_exception`
    - ActiveRecord::DeleteRestrictionErrorを発生させる
  - `:restrict_with_error`
    - 親レコードにエラーを追加する
