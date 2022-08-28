# ActiveRecord::Encryption
- アプリケーションコードとDBの間に暗号化の層を提供する
- ActiveRecord::Encryptionを用いたデータがActive Recordオブジェクトに読み込まれると平文になり、
  DBに置かれると暗号化される

```
# セットアップ: Rails credentialsにキーを追加
$ bin/rails db:encryption:init

# active_record_encryption:
#   primary_key: 非決定論的暗号化で用いるルート暗号化キーを導出するために利用
#   deterministic_key: 決定論的暗号化で用いるルート暗号化キーを導出するために利用
#   key_derivation_salt: 暗号化キーを導出するために利用
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

```ruby
# 書き込みと読み込みは透過的に行われる
user = User.create!(name: 'Bob')
user.take.name

# DBに保存されている内容を直接表示
user = User.connection.execute('SELECT name FROM users LIMIT 1').take
JSON.parse(user['name'])
# => {"p"=>"...", "h"=>{"iv"=>"...", "at"=>"..."}}
# p  - ペイロード (暗号文)
# h  - 暗号化操作に関連する情報を含むヘッダのハッシュ
# iv - 初期化ベクトル
# at - auth_tag (復号時に暗号文が改変されていないことを確認する)
```

## 参照
- [Active Record と暗号化](https://railsguides.jp/active_record_encryption.html)
- [Rails 7のActive Record暗号化機能（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_09_29/109824)
