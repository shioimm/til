# rbenv
## プラグイン
- `rbenv`のコマンドはプラグイン方式になっている
- プラグインは`~/.rbenv/plugins/`以下に配置される

## .ruby-versionとGemfileのRubyのバージョン
- `$ rbenv local`でカレントディレクトリの.ruby-versionのRubyのバージョンが書き変わる
- .ruby-versionとGemfileのRubyのバージョンでは.ruby-versionが優先して利用される
- `bundle exec` / `bin/rails`経由ではGemfileのRubyのバージョンが利用される

## 参照
- [How It Works](https://github.com/rbenv/rbenv/blob/master/README.md#how-it-works)
- [rbenv + ruby-build はどうやって動いているのか](https://takatoshiono.hatenablog.com/entry/2015/01/09/012040)
