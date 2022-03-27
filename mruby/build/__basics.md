# mrubyランタイムのビルド
#### ビルドワークフロー

```
$ git clone --depth=1 git://github.com/mruby/mruby.git
# ./mruby/build_config/<FileName>.rb`の編集を行う
$ cd mruby && rake
```

#### ビルドパイプライン
1. (前提) mrubyのビルド用Rakefileはmruby (`/path/to/mruby/`直下) に同梱されており、
   `$ rake`コマンドの実行によりビルドを開始する
    - mrubyのビルドタスク実行のためにCRubyが必要
2. 設定ファイル`build_config.rb`の読み込み
3. 依存mgemのダウンロード
4. mrubyに必要な最低限の部分と`mrbc`実行ファイルのビルド
    - `mrbc`バイナリは後続のビルドのために必要
4. ソースコードをバイトコード化 -> オブジェクトファイルへコンパイル
    - C -> オブジェクトファイル
    - Ruby -> バイトコード (Cによるデータの配列) -> オブジェクトファイル
4. 依存mgemのビルド -> バイトコード化 -> オブジェクトファイルへコンパイル
5. オブジェクトファイルをアーカイブし`libmruby.a`を作成
6. アーカイブファイル`libmruby.a`をリンクした`mruby`実行ファイル / `mirb`実行ファイルを作成

#### Cの実行ファイルとしてコンパイル
1. アーカイブファイル`./mruby/build/host/lib/libmruby.a`と
   実行ファイルに組み込むCソースファイルをコンパイルし、共有ライブラリ`.so`を作成する
2. 実行ファイルのベースとなるCソースファイルに共有ライブラリ`.so`をリンクし、実行ファイルを作成する

## 参照
- [mruby/mruby](https://github.com/mruby/mruby)
- [オープンソースの言語／mrubyとは](https://www.ossnews.jp/oss_info/mruby)
- [ここまで来た開発言語　mruby・mruby/cの最新情報　“本当に使える”IoTプラットフォーム](https://www.slideshare.net/shimane-itoc/mrubymrubyciot)
- [mrubyをとりあえず動かしてみただけ](https://dojineko.hateblo.jp/entry/2016/02/11/204349)
- Webで使えるmrubyシステムプログラミング入門 Section007
- [Compile](http://forum.mruby.org/docs/index.html)
