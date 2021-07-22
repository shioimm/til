# 新規gem
- [bundle gem](https://bundler.io/man/bundle-gem.1.html)
- [SPECIFICATION REFERENCE](https://guides.rubygems.org/specification-reference/)

```
$ bundle gem GEM_NAME --test=minitest --ci=github
```

```
# GEM_NAME.gemspecを編集

Gem::Specification.new do |spec|
  # ...
  spec.summary       = %q{TODO: Write a short summary, because RubyGems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  # ...
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0") # 動作に最低限必要なバージョン

  # ...
  # 以下の行を消す
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.bindir        = "exe" # ユーザーの実行コマンドはexeに置く
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  # CLIを追加する場合はspec.executables << "command_name"
  spec.require_paths = ["lib"]
```

```
# .gitignoreへ追加

.ruby-version
Gemfile.lock
```

```
$ rake build # ビルド
$ rake release # リリース
```

### API Keyがない場合
- [RubyGems](https://rubygems.org)からAPI Keyを取得
  - Edit settings > API KEYS > New API Key
- API Keyを`~/.gem/credentials`に記述
```
:rubygems_api_key: API_KEY
```

- `credentials`ファイルの権限を`rw-------`へ変更
```
$ chmod 0600 ~/.gem/credentials
```

### バージョンを上げる場合
- `lib/GEM_NAME/version.rb`から`VERSION`へバージョン番号を指定してコミット

```
$ rake build
$ rake release
```
