# mrbgem-template
## TL;DR
- mgemの雛形を生成するコマンド

## Getting Started
```
# コマンドのインストール
$ brew tap mrbgems/mrbgem-template
$ brew install mrbgem-template

# 雛形の生成
$ mrbgem-template -m 2.1.1-rc2 mruby-first_gem
$ cd ./mruby-first_gem
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
