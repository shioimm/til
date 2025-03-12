# mrbgem-template
- mgemの雛形を生成する

```
# mrbgem-templateのインストール
$ brew tap mrbgems/mrbgem-template
$ brew install mrbgem-template

# 雛形の生成
$ mrbgem-template -m mrubyのバージョン 作成するmgemの名前

# (コマンドラインで実行できるバイナリも一緒に生成する場合)
$ mrbgem-template -m mrubyのバージョン --bin-name バイナリの名前 作成するmgemの名前
# -> バイナリの名前.cファイルが生成され、作成されるバイナリのエントリーポイントになる

# mgemディレクトリへ移動
$ cd ./mgemの名前

# ビルド時は逐次バイナリを実行するマシンでrakeを実行
$ rake
# -> mruby/ディレクトリを作り、mrubyのソースコードをチェックアウトする
```

## 生成されるファイル群
- `Rakefile`
  - テスト、ビルド用 (デフォルトのまま使用する)
- `mrbgem.rake`
  - mgemのビルドに必要な情報を記述する (mgem用の`build_config.rb`のようなもの)
- `作成したmgemの名前.gem`
  - 作成したmgemの説明をYAML形式で記述する
  - mgemのインストールにあたって内部で利用する
  - mgem-listに公開される
- `mruby/`
  - 動作確認用のmrubyのソースコードをチェックアウトするディレクトリ
  - mgemをビルドする際の`$ rake`コマンド実行時に自動的にmrubyのソースコードをダウンロードする
- `mrblib/`
  - mgemのソースコード (Ruby) を配置するディレクトリ
  - `mrblib`配下のファイルは自動で辞書順に全て読み込まれる
- `src/`
  - mgemのソースコード (C) を配置するディレクトリ
- `test/`
  - テストコードを配置するディレクトリ
- `tools/`
  - 作成したmgemに添付するコマンドラインツールを配置する

## 参照
- [mruby-mrbgem-template](https://github.com/matsumotory/mruby-mrbgem-template)
- Webで使えるmrubyシステムプログラミング入門 Section019
