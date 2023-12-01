# テストを修正したコミットを`bundled_gems`に取り込む
- net-ftpのテストの修正が必要だった
- net-ftpのテストを修正するためのPRをマージしてもらった後、該当のコミットを`bundled_gems`に指定

```
# gems/bundled_gems

# ...
net-ftp         0.2.0   https://github.com/ruby/net-ftp <コミットハッシュ>
# ...
```
