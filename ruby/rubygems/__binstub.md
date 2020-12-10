# binstub
- 参照: [【翻訳+解説】binstubをしっかり理解する: RubyGems、rbenv、bundlerの挙動](https://techracho.bpsinc.jp/hachi8833/2016_08_24/25037)
- binstub = 実行可能ファイルのラッパースクリプト

## Rubyにおけるbinstub
### RubyGems
- RubyGemsでgemをインストールしたとき、gemには二つの実行可能ファイルが存在する
- rspec-coreの場合
  - `<ruby-prefix>/lib/ruby/gems/バージョン/gems/rspec-core-XX.YY/exe/rspec` -> 本来の実行可能ファイル
  - `<ruby-prefix>/bin/rspec` -> RubyGemsが生成するbinstub
    - binstubが配置されるディレクトリは$PATHが通っている必要がある
- RubyGemsは、gemの種類を問わず本来の実行可能ファイルを呼び出す$LOAD_PATHを準備するためにbinstubを用意する

### rbenv
- rbenvは$PATHにshimディレクトリを追加する
- Rubyに関連する全実行可能ファイルのbinstubはshimディレクトリ以下に配置される
- rbenvは、Ruby実行可能ファイルんの呼び出し時に`rbenv exec`を経由させる(指定したバージョンのRubyで実行する)ためにshimファイルを用意する
