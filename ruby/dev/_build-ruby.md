# build-ruby環境でテストを実行する

```
$ git clone git@github.com:ko1/build-ruby.git

$ cd build-ruby/
$ git clone https://github.com/ruby/ruby.git ruby

$ cd ..
$ cd docker
$ docker build -t rubydev:noble -f Dockerfile.noble .

$ ruby run_sp2_noble.rb trunk-gcc12
```
