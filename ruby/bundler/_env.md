# 環境変数
## `BUNDLE_GEMFILE`
- 特定のGemfileをBundlerが使用するべきGemfileとしてを指定する

```
BUNDLE_GEMFILE=/path/to/Gemfile
```

#### e.g.
```
$ BUNDLE_GEMFILE=./Gemfile.local bundle install
```

```ruby
# ./Gemfile.local

gemfile_path = File.expand_path('./Gemfile', __dir__)
eval File.read(gemfile_path)

dependencies.delete_if { |d| d.name == 'rails' }
gem 'rails', github: 'rails/rails', branch: '7-0-stable'
```

## `BUNDLE_PATH`
- gemのインストール先を指定する (vendor/bundle/など)

```
$ BUNDLE_PATH=path/to/install
```
