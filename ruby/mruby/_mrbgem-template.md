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
$ mrbgem-template -m 2.1.1-rc2 mgemの名前

# バイナリも一緒に生成する場合
$ mrbgem-template -m 2.1.1 --bin-name バイナリの名前 mgemの名前

# mgemディレクトリへ移動
$ cd ./mgemの名前

# ビルド時は逐次rakeを実行
$ rake
```

## 雛形の内容
- Rakefile
  - テスト、ビルド用
- mrbgem.rake
  - mgemのビルドに必要な情報を記述する(`build_config.rb`のようなもの)
- mruby-first_gem.gem
  - mgemの説明をYAML形式で記述する
  - mgemのインストールのために内部で利用する
- mruby/
  - mgemの動作確認のためのmrubyをチェックアウトするディレクトリ
- mrblib/
  - Rubyで書かれたmgemのソースコードを配置するディレクトリ
- src/
  - Cで書かれたmgemのソースコードを配置するディレクトリ
- test/
  - テストコードを配置するディレクトリ
