# credentials.yml.enc
- 本番環境で使用する秘密情報を管理するためのファイル
- 内容は暗号化されている
- デフォルトでアプリケーションの`secret_key_base`が含まれる
- 外部API向けのアクセスキーなどのcredentialも追加できる

#### `config/master.key` or `ENV[RAILS_MASTER_KEY]`
- credentialファイルを暗号化・復号するためのマスターキー

```
# 表示
$ rails credentials:show

# 編集
# credentials.yml.encが存在しない場合はconfig/配下に新たにcredentials.yml.enc、master.keyが追加される
# 同時に.gitignoreに/config/master.keyが追記される
$ rails credentials:edit
```

```yml
# config/credentials.yml.enc (復号)
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
```

```
# credentialファイル内の秘密情報へのアクセス

Rails.application.credential.some_api_key # => SOMEKEY
```

### `secret_key_base`
- `Rails.application.key_generator`メソッドのsecret入力として使われる値

#### `Rails.application.key_generator`メソッド
- `ActiveSupport::CachingKeyGenerator`インスタンス (アプリケーションのKeyGenerator) を返す
- `ActiveSupport::CachingKeyGenerator#generate_key`でキーを導出し、内部のハッシュにキャッシュして保存する
- 導出したキーは以下の箇所で使用される
  - 暗号化cookie: coookies.encryptedでアクセス可能
  - HMAC署名されたcookie: cookies.encryptedでアクセス可能
  - アプリのすべての名前付き`message_verifier`インスタンス

## 参照
- Ruby on Rails 6エンジニア養成読本 押さえておきたい！Rails 6で改善された機能一覧
- [Railsの`secret_key_base`を理解する（翻訳）](https://techracho.bpsinc.jp/hachi8833/2017_10_24/46809)
