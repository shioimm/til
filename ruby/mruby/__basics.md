# mruby
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

## mrubyのソースコードから作成されるバイナリ
### `bin/mruby`
- `mruby`コマンド(`$ ruby`に相当)
- `libmruby.a`を組み込んで任意のRubyスクリプトを実行できるようにしたバイナリ

```
$ echo 'p Hello.' > sample.rb
$ bin/mruby sample.rb # sample.rbを実行
Hello
```

### `bin/mirb`
- 対話型mrubyシェル(`$ irb`に相当)

```
$ bin/mirb
mirb - Embeddable Interactive Ruby Shell

> 'Hello.'
 => "Hello."
```

### `bin/mrbc`
- バイトコードコンパイラ
  - ソースコードをmruby VM上で実行できるようなバイトコードへコンパイルする

```
$ bin/mrbc sample.rb      # Rubyスクリプトsample.rb -> オブジェクトファイルsample.mrb
$ bin/mruby -b sample.mrb # sample.mrbを実行

Hello
```

#### `mrbc`の特徴
- 純粋なバイナリ形式のバイトコードを生成することができる
- Cのデータの配列形式のバイトコードを生成することができる
  - -> 他のCソースコードから読み込み可能
  - -> Cのコンパイラに渡すことが可能
  - mrubyのビルドパイプラインにおいては、Cのデータの配列形式のバイトコードから
    オブジェクトファイルを生成し、まとめてリンクする戦略を取っている

## 関連プロジェクト
- [Related Projects](https://github.com/mruby/mruby/wiki/Related-Projects)

## 参照
- [mruby/mruby](https://github.com/mruby/mruby)
- [オープンソースの言語／mrubyとは](https://www.ossnews.jp/oss_info/mruby)
- [ここまで来た開発言語　mruby・mruby/cの最新情報　“本当に使える”IoTプラットフォーム](https://www.slideshare.net/shimane-itoc/mrubymrubyciot)
- [mrubyをとりあえず動かしてみただけ](https://dojineko.hateblo.jp/entry/2016/02/11/204349)
- Webで使えるmrubyシステムプログラミング入門 Section007
