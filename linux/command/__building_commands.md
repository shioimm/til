# What is the difference between yum, apt-get, rpm, ./configure && make install?
- いずれも異なるレベルで動作する

## パッケージのダウンロード・インストール
### `rpm`
- Redhat Package Manager
- 設定・コンパイル済みのソフトウェアをシステムにインストールする
  - アンインストール・依存関係のリストも付属している
- 多くのディストリビューションにおいて使用されている

### `yum` / `apt`
- `rpm`の追加ラッパー(`yum` - Red Hat系 / `apt` - Debian系)
- 該当のディストリビューションにおいて利用可能な`rpm`ファイルリポジトリ
- パッケージ同士は依存関係を自動的に解決する
- `yum`パッケージおよび依存関係のある位パッケージは簡単にアンインストールが可能

## ソースコードからのビルド・インストール
### `./configure && make install`
- ソースコードから直接ライブラリや実行可能ファイルをビルドし、インストールする
- どのソフトウェアがどのファイルをインストールしたのかを知ることはできない
- システムからインストールされたファイル群を削除するにあたり信頼できる方法がない

#### `.configure`
- 慣例的に`.configure`と名付けられることが多い
- インストールに必要な環境変数やライブラリが正しく設定、設置されているかなどをチェックするスクリプトファイル
- 実行後にMakefileを生成する

#### `make`
- `./configure`の実行で生成されたMakefileに基づいてコンパイルを行う

#### `make install`
- `make`の実行でコンパイルされたプログラムをインストールする
- 最終的なファイルをシステムにコピーするだけ / 依存関係は考慮されない
  - `make uninstall`が用意されている場合もある

## 参照
- [What is the difference between yum, apt-get, rpm, ./configure && make install?](https://superuser.com/questions/125933/what-is-the-difference-between-yum-apt-get-rpm-configure-make-install/125939#125939)
- [configure, make, make install とは何か](https://qiita.com/chihiro/items/f270744d7e09c58a50a5)
