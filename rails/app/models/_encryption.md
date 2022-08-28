# 暗号化

```
# セットアップ: Rails credentialsにキーを追加
$ bin/rails db:encryption:init

# active_record_encryption: primary_key, deterministic_key, key_derivation_salt
```

```ruby
class User < ApplicationRecord
  encrypts :name

  # 大文字小文字を区別しない
  encrypts :email, downcase: true

  # 決定論的暗号化 (同じコンテンツなら同じ暗号文が生成される)
  # デフォルトは非決定論的暗号化
  # 決定論的に暗号化されたデータのみuniquenessバリデーションを利用できる
  encrypts :address, deterministic: true
end
```

- 暗号化された属性 + Base64エンコーディング + メタデータがDBに保存されるようになる
- 510バイト以上のデータを保存できるカラムが必要

## 参照
- [Active Record と暗号化](https://railsguides.jp/active_record_encryption.html)
