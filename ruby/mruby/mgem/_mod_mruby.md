# mod_mruby
- 参照: [matsumotory/mod_mruby](https://github.com/matsumotory/mod_mruby)

## TL;DR
- Apache httpd上にRubyでApacheモジュールを実装するためのWebサーバー拡張機構
- 高速でメモリ効率が良いことが特徴

## Get Started
#### (1) Apache本体とApacheのモジュールをビルドするためのツールをインストール
- apache2
- apache2-dev
- apache2-utils
- libssl-dev

#### (2) mod_mrubyをインストール
```
$ git clone https://github.com/matsumotory/mod_mruby.git
$ cd mod_mruby
$ sh build.sh
$ sudo make install # Apacheの拡張としてmod_mrubyがインストールされる
```

#### (3) mod_mrubyを有効化
```
$ sudo a2enmod mruby
```

#### (4) Apacheを再起動
```
$ systemctl restart apache2
```

## Apache拡張手順
#### (1) モジュールを記述
```ruby
# /var/lib/mruby/hello.rb
Apache.echo "hello"
```
- 必要な外部ライブラリがある場合、
  mod_mruby/build_config.rbに`conf.gem github: 'xxxx/xxxx'`を記述、
  必要なヘッダファイルをインストールの上mod_mrubyを再ビルドする
```
$ sh build.sh
$ sudo make install

$ ldd /usr/lib/apache2/modules/mod_mruby.so # ビルドがうまくいっているかを確認
```

#### (2) Apacheにモジュールを呼び出すためのconfを追加
```
# /path/to/conf/xxxx.conf

<Location /hello>
  mrubyHandlerMiddle /var/lib/mruby/hello.rb
</Location>
```
- [ディレクティブ](https://github.com/matsumotory/mod_mruby/wiki/Directives#directive)

#### (3) Apacheを再起動
```
$ sudo systemctl apache2 restart
```
