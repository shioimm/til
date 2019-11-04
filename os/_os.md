### PATHについて
- 参照: [PATHを通すとは？ (Mac OS X)](https://qiita.com/soarflat/items/09be6ab9cd91d366bf71)
- 参照: [PATHを通すために環境変数の設定を理解する (Mac OS X)](https://qiita.com/soarflat/items/d5015bec37f8a8254380)
- PATH = コマンド検索パス
  - シェルがコマンド実行ファイルを探しに行くパス
  - PATHを通す -> コマンド探索パスを追加する
- コマンド探索パスは`$PATH`環境変数に設定されている
```
❯❯❯ echo $PATH
/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```
- :区切りで複数のパスが登録されている
  - /usr/local/bin
  - /usr/local/sbin
  - /usr/bin
  - /bin
  - /usr/sbin
  - /sbin
```
# touchコマンドの場合
# binディレクトリにtouchコマンド実行ファイル格納されている
❯❯❯ which touch
/usr/bin/touch
```
