# binstub
#### binstub概要
- 実行可能ファイルをラップしたスクリプト
- 実行可能ファイルを呼び出す前に環境を整える目的で使用される

### gemにおけるbinstub
- 本来の実行可能ファイルを呼び出す前に`$LOAD_PATH`を準備する目的で使用される
- gemのインストール時 (`gem install`) 、gemは二つの実行可能ファイルを提供する
  - 本来の実行ファイル ($PATHに含まれていないディレクトリに配置される)
  - binstub ($PATHに含まれているディレクトリに配置される)

### rbenv
- rbenvは$PATHにshimディレクトリを追加し、
- Rubyに関連する全実行可能ファイルのbinstubがshimディレクトリの下に配置される
  - `ruby`コマンド
  - gemのbinstubコマンド
  - システムにインストールされている各Rubyバージョンのgemのbinstubコマンド
- rbenvはshimファイルを利用することによって
  Ruby実行可能ファイル呼び出し時に`rbenv exec`を経由させる (指定したバージョンのRubyで実行する)

#### 呼び出し順
1. rbenv shimのbinstub
   `$RBENV_ROOT/shims/BINSTUB`
2. gemのbinstub
   `$RBENV_ROOT/versions/RUBY_VERSION/bin/BINSTUB`
3. 本来の実行可能ファイル
   `$RBENV_ROOT/versions/RUBY_VERSION/lib/ruby/gems/RUBY_VERSION/gems/GEM_NAME/exe/BINSTUB`

### Bundler
- Bundlerが管理するプロジェクトディレクトリごとにbinstubを生成して利用することができる
- プロジェクトのbinstubは慣例としてプロジェクトローカルのbin/ディレクトリに配置される

```
# bundleされたすべてのgemのbinstubを一括生成する
$ bundle install --binstubs

# gemを指定してbinstubを生成する
bundle binstubs GEM_NAME
```

## 参照
- [binstubをしっかり理解する: RubyGems、rbenv、bundlerの挙動（翻訳+解説）](https://techracho.bpsinc.jp/hachi8833/2021_11_22/25037)
