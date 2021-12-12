# ActiveRecord::Encryption
- アプリケーションコードとDBの間に暗号化の層を提供する
- ActiveRecord::Encryptionを用いたデータがActive Recordオブジェクトに読み込まれると平文になり、
  DBに置かれると暗号化される

## Usage
#### キーセットの追加
```
# credentialファイルにキーセットを追加する
$ bin/rails db:encryption:init

# active_record_encryption:
#   primary_key: 非決定論的暗号化で用いるルート暗号化キーを導出するために利用
#   deterministic_key: 決定論的暗号化で用いるルート暗号化キーを導出するために利用
#   key_derivation_salt: 暗号化キーを導出するために利用
```

#### configファイル
- [Configuration Options](https://edgeguides.rubyonrails.org/active_record_encryption.html#configuration-options)

#### モデル
```ruby
class Event < ApplicationRecord
  # locationカラムを暗号化
  encrypts :location
```

```ruby
# 書き込みと読み込みは透過的に行われる
event = Event.create!(location: 'somewhere')
event.first.location

# DBに保存されている内容を直接表示
event = Event.connection.execute('SELECT location FROM events LIMIT 1').first
JSON.parse(event['location'])
# => {"p"=>"...", "h"=>{"iv"=>"...", "at"=>"..."}}
# p  - ペイロード (暗号文)
# h  - 暗号化操作に関連する情報を含むヘッダのハッシュ
# iv - 初期化ベクトル
# at - auth_tag (復号時に暗号文が改変されていないことを確認する)
```

## 参照
- [Rails 7のActive Record暗号化機能（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_09_29/109824)
