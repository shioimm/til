# Fukuoka.rb #256 メモ
- echoserver.c (echoserver)
- addrinfo.rb (addrinfo.c) - Cソースコードとして実行する
- addr2int.rb - Rubyスクリプトとして実行する
- client.rb - クライアント

```
# addrinfo.rbをCソースファイルaddrinfo.cへ変換
# (echoserver.cの中でaddrinfo.cをincludeする)
$ mruby/bin/mrbc -Baddrinfo addrinfo.rb

# mrubyをリンクしてechoserverをコンパイル
$ gcc -std=c99 -Imruby/include echoserver.c -o echoserver mruby/build/host/lib/libmruby.a -lm

# サーバーを起動
```
