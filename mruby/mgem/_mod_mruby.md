# `mod_mruby`
- Apache httpd上にRubyでApacheモジュールを実装するためのWebサーバー拡張機構
- 高速でメモリ効率が良いことが特徴

## Get Started
- Ubuntu 18.04.4 LTS

#### (1) Apache本体とApacheのモジュールをビルドするためのツールをインストール
- `apache2`
- `apache2-dev`
- `apache2-utils`
- `libssl-dev`

#### (2) `mod_mruby`をインストール
```
$ git clone https://github.com/matsumotory/mod_mruby.git
$ cd mod_mruby

# ビルド用のチェルスクリプトを実行
$ sh build.sh
# /src/.libs/mod_mruby.so がビルドされる

# mod_mruby.soをインストール
$ sudo make install
# パッケージでインストールしたApacheの拡張としてmod_mrubyがインストールされる
#   -> /etc/apache2/mods-avalable/mruby.load が追加される
#        LoadModule mruby_module /usr/lib/apache2/modules/mod_mruby.so
```

#### (3) `/etc/apache2/mods-avalable/mruby.conf`へ設定を追加
```
<Location /hello>
  mrubyHandlerMiddleCode 'Apache.echo "Hello"'
</Location>
```

#### (4) `mod_mruby`を有効化
```
$ sudo a2enmod mruby
```

#### (5) Apacheを再起動
```
$ sudo systemctl restart apache2
```

## Apache拡張手順
#### (1) モジュールを記述
```ruby
# /var/lib/mruby/hello.rb

Apache.echo "hello"
```
- 必要な外部ライブラリがある場合、
  `mod_mruby/build_config.rb`に`conf.gem github: 'xxxx/xxxx'`を記述、
  必要なヘッダファイルをインストールの上`mod_mruby`を再ビルドする
```
$ sh build.sh
$ sudo make install

$ ldd /usr/lib/apache2/modules/mod_mruby.so # ビルドがうまくいっているかを確認
```

#### (2) Apacheにモジュールを呼び出すためのconfを追加
- [ディレクティブ](https://github.com/matsumotory/mod_mruby/wiki/Directives#directive)
```
# /etc/apache2/mods-avalable/mruby.conf

<Location /hello>
  mrubyHandlerMiddle /var/lib/mruby/hello.rb
</Location>
```

#### (3) Apacheを再起動
```
$ sudo systemctl apache2 restart
```

## 参照
- [matsumotory/`mod_mruby`](https://github.com/matsumotory/mod_mruby)
- Webで使えるmrubyシステムプログラミング入門 Section026
