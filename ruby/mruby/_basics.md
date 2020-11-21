# mruby
- 参照: [mruby/mruby](https://github.com/mruby/mruby)
- 参照: [オープンソースの言語／mrubyとは](https://www.ossnews.jp/oss_info/mruby)
- 参照: [ここまで来た開発言語　mruby・mruby/cの最新情報　“本当に使える”IoTプラットフォーム](https://www.slideshare.net/shimane-itoc/mrubymrubyciot)
- 参照: [mrubyをとりあえず動かしてみただけ](https://dojineko.hateblo.jp/entry/2016/02/11/204349)
- 参照: Webで使えるmrubyシステムプログラミング入門 Section007

## TL;DR
- 組み込みシステム向けの軽量なRuby言語処理系
- mruby VMを持ち、mruby VM上で動作する
  - Rubyスクリプトを動的にバイトコードに変換し、mruby VM上で実行する
  - 事前に生成したバイトコードを直接mruby VMに渡し、mruby VM上で実行する
- モジュール化されており、他のアプリケーション内にリンクして組み込むことが可能な設計となっている
- ソースコード・mgemを含めてワンバイナリとしてビルドすることができる

## 特徴
- コンパイラ言語
  - mruby VM上で動作し、環境に依存しない
  - バイトコードコンパイラmrbcを同梱
- C - mruby間での相互互換性・モジュラビリティ
- インクリメンタルGC
- 省メモリ

## mrubyのビルドパイプライン
1. `$ rake`実行 -> `Rakefile`の読み込み
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
6. アーカイブファイル`libmruby.a`をリンクした実行可能なバイナリの生成

## mrubyが使用するバイナリ
### `bin/mruby`
- `mruby`コマンド(`$ ruby`に相当)
- `libmruby.a`を組み込んで任意のRubyスクリプトを実行できるようにしたバイナリ
```sh
$ echo 'p Hello.' > sample.rb
$ bin/mruby sample.rb # sample.rbを実行
Hello
```

### `bin/mirb`
- 対話型mrubyシェル(`$ irb`に相当)
```sh
$ bin/mirb
mirb - Embeddable Interactive Ruby Shell

> 'Hello.'
 => "Hello."
```

### `bin/mrbc`
- バイトコードコンパイラ
  - ソースコードをmruby VM上で実行できるようなバイトコードへコンパイルする
```ruby
$ bin/mrbc sample.rb      # Rubyスクリプトsample.rb -> オブジェクトファイルsample.mrb
$ bin/mruby -b sample.mrb # sample.mrbを実行

Hello
```

### `mrbc`の特徴
- 純粋なバイナリ形式のバイトコードを生成することができる
- Cのデータの配列形式のバイトコードを生成することができる
  - -> 他のCソースコードから読み込み可能
  - -> Cのコンパイラに渡すことが可能
  - mrubyのビルドパイプラインにおいては、Cのデータの配列形式のバイトコードから
    オブジェクトファイルを生成し、まとめてリンクする戦略を取っている

## 設定ファイル
### `build_config.rb`
- mrubyをビルドするための設定ファイル
- 依存mgemを宣言すると、mgem内部のプログラムをすべて読み込んだmrubyをビルドすることができる
  - `require`なしでmgemを利用できる
```ruby
MRuby::Build.new do |conf| # confはMRuby::Buildのインスタンス
  toolchain           # どのツールチェインでビルドするか

  conf.gem            # 依存mgemの記述 :core/:mgem/:github
  conf.gembox         # まとまったmgemグループを一括で読み込み
  enable_debug        # デバッグビルドを有効にする
  conf.enable_test    # テストを有効にする
  conf.enable_bintest # bintest(バイナリを実行するテスト)を有効にする
  conf.cc             # コンパイラに特殊なオプションを渡す
  conf.linker         # リンカに特殊なオプションを渡す
  conf.archiver       # アーカイバに特殊なオプションを渡す
end
```

## 関連プロジェクト
- [Related Projects](https://github.com/mruby/mruby/wiki/Related-Projects)
