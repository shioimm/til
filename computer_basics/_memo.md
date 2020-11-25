# 備忘録
## What is the difference between yum, apt-get, rpm, ./configure && make install?
- 参照: [What is the difference between yum, apt-get, rpm, ./configure && make install?](https://superuser.com/questions/125933/what-is-the-difference-between-yum-apt-get-rpm-configure-make-install/125939#125939)
- いずれも異なるレベルで動作する

### `./configure && make install`
- ソースコードから直接ライブラリや実行可能ファイルをビルドし、インストールする
  - `.configure` - 多くのオプションがあり、パッケージをカスタマイズすることができる
  - `make install` - 最終的なファイルをシステムにコピーするだけ / 依存関係は考慮されない
    - `make uninstall`が用意されている場合もある
- どのソフトウェアがどのファイルをインストールしたのかを知ることはできない
- システムからインストールされたファイル群を削除するにあたり信頼できる方法がない

### `rpm`
- Redhat Package Manager
- 設定・コンパイル済みのソフトウェアをシステムにインストールする
  - アンインストール・依存関係のリストも付属している
- 多くのディストリビューションにおいて使用されている

### `yum`
- `rpm`の追加ラッパー
- 該当のディストリビューションにおいて利用可能な`rpm`ファイルリポジトリ
- パッケージ同士は依存関係を自動的に解決する
- `yum`パッケージおよび依存関係のある位パッケージは簡単にアンインストールが可能

### `apt`
- Debianシステムにおける`yum`
