# mrbgem-template
- 参照: [mruby-mrbgem-template](https://github.com/matsumotory/mruby-mrbgem-template)

## TL;DR
- mgemの雛形を生成するコマンド

## Getting Started
```
# コマンドのインストール
$ brew tap mrbgems/mrbgem-template
$ brew install mrbgem-template

# 雛形の生成
$ mrbgem-template -m mrubyのバージョン 作成するmgemの名前

# バイナリも一緒に生成する場合
$ mrbgem-template -m mrubyのバージョン --bin-name バイナリの名前 作成するmgemの名前

# mgemディレクトリへ移動
$ cd ./mgemの名前

# ビルド時は逐次バイナリを実行するマシンでrakeを実行
$ rake
```

## 生成されるファイル群
- `Rakefile`
  - テスト、ビルド用
- `mrbgem.rake`
  - mgemのビルドに必要な情報を記述する(`build_config.rb`のようなもの)
- `作成したmgemの名前.gem`
  - 作成したmgemの説明をYAML形式で記述する
  - mgemのインストールにあたって内部で利用する
  - mgem-listに公開される
- `mruby/`
  - 動作確認のためmrubyのソースコードをチェックアウトするディレクトリ
  - `$ rake`コマンドを実行することで自動的にmrubyのソースコードをダウンロードする
- `mrblib/`
  - Rubyで書かれたmgemのソースコードを配置するディレクトリ
  - `mrblib`配下のファイルは自動で辞書順に全て読み込まれる
- `src/`
  - Cで書かれたmgemのソースコードを配置するディレクトリ
- `test/`
  - テストコードを配置するディレクトリ
- `tools/`
  - 作成したmgemに添付するコマンドラインツールを配置する
