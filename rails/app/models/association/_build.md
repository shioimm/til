# `build_ASSOCIATION`
- [4.2.1.3 `build_association(attributes = {})`](https://railsguides.jp/association_basics.html#has-one%E3%81%A7%E8%BF%BD%E5%8A%A0%E3%81%95%E3%82%8C%E3%82%8B%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89-build-association-attributes)
- e.g. `User has_one Profile`の場合:
  すでに`User`に紐づく`Profile`レコードが存在する状況で`User.build_profile`を使うと、
  既存の`Profile`レコードの`user_id`が`nil`にupdateされてしまう
  (後から生成された方の`Profile`レコードのみが`User`レコードとの紐付きを持つ状態になる)
  - `Profile`に`validetes :user_id, uniqueness: true`が指定されていたり、
    `add_index :profiles, :user_id, unique: true`が設定されていても、
    既存の`Profile`レコードの`user_id`が`nil`になるため全ての制約をすり抜ける
  - そのため、重複してレコードが生成される可能性がある場合は
    `User.build_profile`ではなく`Profile.new`を使う
  - `build_profile`を呼んだ時点で既存の`Profile`レコードにupdateが実行されるため、
    `User.build_profile`で生成したレコードを保存しなかった場合、
    単に`User`レコードと既存の`Profile`レコードの関連が失われる
