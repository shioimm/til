```
$ ssh #{username}@#{ログインしたいrubyci}

# Rubyのビルド
$ mkdir dev
$ cd dev

$ git clone https://github.com/ruby/ruby.git
$ cd ruby
$ ./autogen.sh

$ cd ../
$ mkdir ~/.rubies
$ mkdir build
$ cd build

$ ../ruby/configure --prefix="${HOME}/.rubies/ruby-master" --with-baseruby=/home/chkbuild/.rbenv/shims/ruby
$ make
```
