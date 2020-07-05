# mruby
- 参照: [mruby/mruby](https://github.com/mruby/mruby)
- 参照: [オープンソースの言語／mrubyとは](https://www.ossnews.jp/oss_info/mruby)
- 参照: [ここまで来た開発言語　mruby・mruby/cの最新情報　“本当に使える”IoTプラットフォーム](https://www.slideshare.net/shimane-itoc/mrubymrubyciot)
- 参照: [mrubyをとりあえず動かしてみただけ](https://dojineko.hateblo.jp/entry/2016/02/11/204349)

## TL;DR
- 組み込みシステム向けの軽量なRuby言語処理系
- モジュール化されており、他のアプリケーション内にリンクして組み込むことが可能な設計となっている

## 特徴
- コンパイラ言語
  - mruby VM上で動作し、環境に依存しない
  - 実行形式の自由度が高い
    - バイトコードに変換しての実行
    - mrubyスクリプトのままの実行
- C言語-mruby間での相互互換性・モジュラビリティ
- インクリメンタルガベージコレクション
- 省メモリ

## Usage
- `$ git clone`後、`$ ruby ./minirake`を実行することで`bin/`以下に次のバイナリが生成される
  - mirb
  - mruby
  - mrbc

### mirb
- 対話型mrubyシェル(`$ irb`に相当)
```sh
$ bin/mirb
mirb - Embeddable Interactive Ruby Shell

> 'Hello.'
 => "Hello."
```

### mruby
- インタプリタ(`$ ruby`に相当)
```sh
$ echo 'p Hello.' > sample.rb
$ bin/mruby sample.rb # sample.rbを実行
Hello
```

### mrbc
- バイトコードコンパイラ
```ruby
$ bin/mrbc sample.rb # バイトコードへ変換
$ bin/mruby -b sample.mrb # バイトコードとしてsample.mrbを実行(-bオプション必須)
Hello
```

## 関連プロジェクト
- [Related Projects](https://github.com/mruby/mruby/wiki/Related-Projects)

# mruby/c
- 参照・引用: [mruby／c](https://www.s-itoc.jp/activity/research/mrubyc/)

## TL;DR
- 小型・省電力デバイス向けのmruby実装
- 従来のmrubyを更に軽量化

## 特徴
- mrubyとバイトコードは互換
- 省メモリ
  - 従来のmruby比で10分の1程度(メモリ消費50KB未満(RAM)で稼働)
- コンカレントな動作
  - OSを使用せず複数のRubyプログラムを同時に動かすことが可能

# mrubyとmruby/cの違い
- Rubyの機能
  - mruby -> Rubyのほぼ全ての機能をサポート・多くのgem
  - mruby/c -> Rubyの最小の機能のみをサポート
- 実効性能
  - mruby -> 実効性能が高い
  - mruby/c -> 少ないメモリで動作する
- OSの利用
  - mruby -> OSありを想定
  - mruby/c -> OSなしを想定
