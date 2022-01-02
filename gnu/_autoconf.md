# Autoconf
- configureスクリプトを自動生成するためのツール
- Autoconfは設定ファイルconfigure.inを読み込み、configureスクリプトを生成する

##### configureスクリプト
- config.h (ヘッダファイル) やMakefileを生成するシェルスクリプト
  - config.hはconfig.h.inを元に生成され、MakefileはMakefile.inを元に生成される
- configureスクリプトはどの環境でも必ず動く

## Autoconfを使用してMakefileを実行するまでの手順
1. autoconfコマンドを実行 -> configureスクリプトが生成される
2. ./configureスクリプトを実行 -> 環境に応じたMakefileが生成される
3. makeコマンドでMakefileを実行する

## 参照
- [Autoconf](https://www.gnu.org/software/autoconf/)
- [configureスクリプトとは何なのか](https://engineering.otobank.co.jp/entry/2015/02/19/124500)
- [autoconfを使ってconfigureを作って配布](https://nullnull.hatenablog.com/entry/20120711/1342014234)
