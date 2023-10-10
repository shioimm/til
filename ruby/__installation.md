# インストール
## Homebrew

```
$ brew update
$ brew upgrade rbenv
$ cd "$(rbenv root)/plugins/ruby-build"
$ git pull --rebase
$ rbenv install *.*.*
```

## Ubuntu

```
$ sudo apt update
$ sudo apt install gcc make
$ sudo apt install libssl-dev zlib1g-dev

$ git clone --depth 1 https://github.com/rbenv/rbenv.git ~/.rbenv

# rbenv の高速化
$ cd ~/.rbenv && src/configure && make -C src

$ git clone --depth 1 https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

$ rbenv install -l
$ rbenv install *.*.*
$ rbenv global *.*.*
```

- https://qiita.com/kerupani129/items/77dd1e3390b53f4e97b2
