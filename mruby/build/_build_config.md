# `build_config.rb`
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

```ruby
# デバッグ情報の付与
conf.cc.flags << '-fPIC -O0 -g -fno-omit-frame-pointer'

# -fPIC - 位置独立
# -O0   - 最適化レベル0 (最適化を行わない)
# -g    - バイナリにデバッグ情報を生成
# -fno-omit-frame-pointer - フレームポインタを表示できるように最適化を抑制
```

## 参照
- [mruby/mruby](https://github.com/mruby/mruby)
- [オープンソースの言語／mrubyとは](https://www.ossnews.jp/oss_info/mruby)
- [ここまで来た開発言語　mruby・mruby/cの最新情報　“本当に使える”IoTプラットフォーム](https://www.slideshare.net/shimane-itoc/mrubymrubyciot)
- [mrubyをとりあえず動かしてみただけ](https://dojineko.hateblo.jp/entry/2016/02/11/204349)
- Webで使えるmrubyシステムプログラミング入門 Section007
- [Compile](http://forum.mruby.org/docs/index.html)
