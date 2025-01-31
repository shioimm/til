# MRIのビルド手順
#### 必要なコマンド
- git
- ruby
- autoconf (`configure`スクリプトの自動生成ツール)
- bison (パーサージェネレータ)
- gcc
- make

#### ディレクトリ構造
- workdir/
  - `ruby/`    - MRIソースコードを格納するディレクトリ
  - `build/`   - ビルドしたRubyを格納するディレクトリ
  - `install/` - `build/`に格納されているRubyをインストールするディレクトリ

## ビルド手順
```
# 準備
$ mkdir workdir && cd "$_"
$ git clone https://github.com/ruby/ruby.git

# 1. workdir/ruby/にconfigureスクリプトを生成
$ cd ruby
$ ./autogen.sh

# 2. ビルドディレクトリを作成
$ cd../
$ mkdir build
$ cd build

# 3. ビルドディレクトリ直下でconfigureスクリプトを実行しcommon.mkを生成
$ ../ruby/configure --prefix=$PWD/../install --enable-shared

# (--prefix: インストール先をworkdir/install/に指定)
# Homebrewで各種ライブラリをインストールしている場合はconfigureに以下のオプションを追加
# --with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --disable-libedit

# 4. workdir/build/でmakeを実行し、workdir/build/にRubyをビルド (-j: 並列でコンパイルを実行)
$ make -j

# makeで実行される処理:
# - make miniruby - workdir/build/minirubyの生成
# - make encs     - エンコーディング関連拡張ライブラリの生成
# - make exts     - 拡張ライブラリの生成
# - make ruby     - workdir/build/rubyの生成
# - make docs     - rdocの生成

# 5. workdir/build/以下にビルドしたRubyをworkdir/install/にインストール (インストール先は手順2で指定済み)
$ make install

# 6. 開発中のRubyのインストールができていることを確認
$ ../install/bin/ruby -v
```

#### `$ history`

```
$ history

$ cd workdir/
$ cd ruby
$ ./autogen.sh
$ cd ..
$ mkdir build
$ cd build
$ ../ruby/configure --prefix=$PWD/../install --enable-shared --with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --disable-libedit
$ make -j
$ make install
$ ../install/bin/ruby -v
```

#### makeコマンド実行時、ビルドに失敗する場合

```
$ make clean

# それでも失敗する場合
$ make distclean # -> configureスクリプトの実行からやり直す
```

### miniruby
- MRIのビルド終了後、workdir/buid/以下にminiruby (実行ファイル) が生成される
- MRIソースコードを修正した場合、minirubyをビルドし修正結果を確認する

#### 手順
1. workdir/ruby/でMRIソースコードを修正
2. workdir/build/でminirubyをビルド (`$ make miniruby`)
3. workdir/build/で修正を検証 (`$ ./miniruby xxx.rb`)
    - workdir/ruby/test.rbに実行したいスクリプトを記述し、
      workdir/build/で`$ make run`すると手順2、3をまとめて実行できる
    - minirubyではなくRubyをビルドする場合はworkdir/build/で`$ make runruby`を実行する

## パーサのステート一覧を出力する

```
$ touch workdir/ruby/parse.y
$ cd workdir/build/

# ステート一覧を出力したファイルaを作成
$ YFLAGS=" --report=states,itemsets,lookaheads,solved --report-file=a" make main
```

```
# a
# <ステート番号>
#   <ルール番号> <還元先の非終端記号名>: "<還元元となる終端記号>" • <次のトークン>
#     "<次のトークン>"         <指示>  (<還元先の非終端記号>)

State 35
  652 user_variable: "local variable or method" • ["end-of-input", "`rescue'", ...]
  ...
    "end-of-input"         reduce using rule 652 (user_variable)
    "`rescue'"             reduce using rule 652 (user_variable)
    ...
```

## MRIコースコードの構造
- [MRI のソースコードの構造の紹介](https://github.com/ko1/rubyhackchallenge/blob/master/JA/2_mri_structure.md#mri-%E3%81%AE%E3%82%BD%E3%83%BC%E3%82%B9%E3%82%B3%E3%83%BC%E3%83%89%E3%81%AE%E6%A7%8B%E9%80%A0%E3%81%AE%E7%B4%B9%E4%BB%8B)

## 参照
- [Ruby Hack Challenge (RHC)](https://github.com/ko1/rubyhackchallenge)
- [(2) MRI ソースコードの構造](https://github.com/ko1/rubyhackchallenge/blob/master/JA/2_mri_structure.md)
