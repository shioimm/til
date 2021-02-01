# Autoconf
- 参照: [Autoconf](https://www.gnu.org/software/autoconf/)
- 参照: [autoconfを使ってconfigureを作って配布](https://nullnull.hatenablog.com/entry/20120711/1342014234)

## TL;DR
- `configure`スクリプトを自動生成するためのツール
- 設定ファイル`configure.in`を読み込むことで
  OSの種類を判別して`configure`スクリプトを生成する

### `configure`スクリプト
- OS間の差異を吸収するMakefileを生成するシェルスクリプト

## Autoconfを使用してMakefileを実行するまでの手順
1. `autoconf`コマンドを実行 -> `configure`スクリプトが生成される
2. `./configure`スクリプトを実行 -> 環境に応じたMakefileが生成される
3. `make`コマンドでMakefileを実行する
