# Macのカーネルバージョン
```
$ uname -a
Darwin username.local 20.5.0 Darwin Kernel Version 20.5.0: Sat May  8 05:10:33 PDT 2021; root:xnu-7195.121.3~9/RELEASE_X86_64 x86_64

# => Darwin 20.5.0
```

- Rubyの使用するカーネルバージョンはそのRubyをビルドした時点のものになる
```
$ ruby -v
ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin18]

$ rbenv local 3.0.1

$ ruby -v
ruby 3.0.1p64 (2021-04-05 revision 0fb782ee38) [x86_64-darwin20]
```
