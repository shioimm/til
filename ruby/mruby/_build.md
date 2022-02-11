# mrubyのビルド
## `build_config.rb`
- mrubyをビルドするための設定ファイル
- 依存mgemを宣言すると、mgem内部のプログラムをすべて読み込んだmrubyをビルドすることができる
  - `require`なしでmgemを利用できる

```ruby
MRuby::Build.new do |conf| # confはMRuby::Buildのインスタンス
  toolchain :gcc      # どのツールチェイン (gcc / clang) でビルドするか

  conf.enable_debug   # デバッグビルドを有効にする
  conf.enable_test    # テストを有効にする
  conf.enable_bintest # bintest (バイナリを実際に実行して行う結合テスト) を有効にする

  # Cコンパイラ (ccなど) のバイナリ、フラグ、インクルードパスの設定
  conf.cc do |cc|
    ...
  end

  # リンカ (ldなど)のバイナリ、フラグ、ライブラリパスの設定
  conf.linker do |linker|
    ...
  end

  # アーカイバ (arなど) のバイナリとフラグの設定
  conf.archiver do |archiver|
    ...
  end

  conf.gembox 'default'    # まとまったmgemグループを一括で読み込み
  conf.gem core 'mruby-io' # 依存mgemの記述 :core/:mgem/:github
end
```

## ビルドパイプライン
1. mrubyをチェックアウトし、プロジェクトのルートで`$ rake`実行 -> `Rakefile`の読み込み
    - mrubyのビルドタスクはmrubyのソースコードに同梱されている
    - mrubyのビルドタスク実行のためにはCRubyが必要
    - `rake`を使用して依存するファイルを検知し、ビルドタスクを開始する
2. 設定ファイル`build_config.rb`の読み込み
3. 依存mgemのダウンロード -> ここまでで必要なソースコードが揃う
4. mrubyに必要な最低限の部分と`mrbc`バイナリのビルド・バイトコード化
    - `mrbc`バイナリは後続のビルドのために必要
    - CとRubyを同じCのビルドツールで扱うため、
      Cのソースコードはオブジェクトファイルにビルドされ、
      Rubyのコードはバイトコードの配列を記述したCのファイルに変換された後
      オブジェクトファイルにビルドされる
4. 依存mgemのビルド・バイトコード化 -> ここまでで必要なオブジェクトファイルが揃う
5. オブジェクトファイルを結合してアーカイブファイル`libmruby.a`を生成
    - 必要なプログラムが全て入ったビルド済みのライブラリが完成
6. アーカイブファイル`libmruby.a`をリンクした`mruby`バイナリ / `mirb`バイナリの作成

## 参照
- [mruby/mruby](https://github.com/mruby/mruby)
- [オープンソースの言語／mrubyとは](https://www.ossnews.jp/oss_info/mruby)
- [ここまで来た開発言語　mruby・mruby/cの最新情報　“本当に使える”IoTプラットフォーム](https://www.slideshare.net/shimane-itoc/mrubymrubyciot)
- [mrubyをとりあえず動かしてみただけ](https://dojineko.hateblo.jp/entry/2016/02/11/204349)
- Webで使えるmrubyシステムプログラミング入門 Section007
- [Compile](http://forum.mruby.org/docs/index.html)
