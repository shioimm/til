# ソフトウェアのインストール
## パッケージのインストール
#### `dpkg` (Debian系)  / `rpm` (Red Hat系)
- パッケージ管理コマンド
  - Debian系 - deb形式
  - Red Hat系 - apr形式
- 個々のパッケージの単位で扱う
- `rpm`コマンドでインストールしたソフトウェアはRPMデータベースで管理される

#### `apt` (Debian系) / `dnf`, `yum` (Red Hat系)
- `dpkg`、`rpm`のラッパーコマンド
- リポジトリ内のRPMパッケージ同士の依存関係を考慮した統合的な単位で扱う
- RPMパッケージ個々の情報を参照し、依存関係の解決を行う

## ソースコードからのビルド・インストール
- ソースコードから直接ライブラリや実行可能ファイルをビルドし、インストールする
- どのソフトウェアがどのファイルをインストールしたのかを知ることはできない
- システムからインストールされたファイル群を削除するにあたり信頼できる方法がない

```
$ ./configure
$ make
$ sudo make install
```

#### `.configure`
- 慣例的に`.configure`と名付けられることが多い
- インストールに必要な環境変数やライブラリが正しく設定、設置されているかなどをチェックするスクリプトファイル
- 実行後にMakefileを生成する

#### `make`
- `./configure`の実行で生成されたMakefileに基づいてコンパイルを行う

#### `sudo make install`
- コンパイルで生成された実行ファイルを初手英の場所に配置 (インストール) する
- 最終的なファイルをシステムにコピーするだけ / 依存関係は考慮されない
  - `make uninstall`が用意されている場合もある

## 参照
- [What is the difference between yum, apt-get, rpm, ./configure && make install?](https://superuser.com/questions/125933/what-is-the-difference-between-yum-apt-get-rpm-configure-make-install/125939#125939)
- [configure, make, make install とは何か](https://qiita.com/chihiro/items/f270744d7e09c58a50a5)
