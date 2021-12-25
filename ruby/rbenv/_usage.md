# Usage

```
# 実行可能なRubyバージョンの確認
$ rbenv version

# インストール済みのRubyバージョンの確認
$ rbenv versions

# インストール可能かつstableなRubyバージョンの確認
$ rbenv install -l

# インストール可能なすべてのRubyバージョンの確認
$ rbenv install --list-all
```

```
# Rubyのインストール (Homebrew)
$ brew update
$ brew upgrade rbenv
$ cd "$(rbenv root)/plugins/ruby-build"
$ git pull --rebase
$ rbenv install *.*.*
```

## 参照
- [rbenv/rbenv](https://github.com/rbenv/rbenv)
