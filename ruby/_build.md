# MRIのビルド手順
- 参照: [Ruby Hack Challenge (RHC)](https://github.com/ko1/rubyhackchallenge)
  - 参照: [(2) MRI ソースコードの構造](https://github.com/ko1/rubyhackchallenge/blob/master/JA/2_mri_structure.md)

## 必要なコマンド
- git
- ruby
- autoconf(`configure`スクリプトの自動生成ツール)
- bison(パーサージェネレータ)
- gcc
- make

## ディレクトリ構造
```
workdir/
  |- ruby/    MRIソースコードを格納するディレクトリ
  |- build/   コンパイル済みファイルを格納するディレクトリ
  |- install/ 修正後のMRIをインストールするディレクトリ
```

## ビルド手順
(1) `workdir/ruby/`へ移動
```
$ cd workdir/
$ cd ruby
```

(2) `workdir/ruby/`以下に`configure`スクリプトを生成
```
$ autoconf
```

(3) build/以下にMakefileを生成
```
$ cd ..
$ mkdir build
$ cd build

# --prefixオプションでインストール先をworkdir/install/に指定
$ ../ruby/configure --prefix=$PWD/../install --enable-shared

# Homebrewで各種ライブラリをインストールしている場合
$ ../ruby/configure --prefix=$PWD/../install --enable-shared --with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --disable-libedit
```

(4) `workdir/build/`からMakefileを実行してMRIのビルドを行う
```
# -jオプションで並列にコンパイルを行う
$ make -j
```
- `make`コマンドで以下の処理がまとめて実行される
  - `make miniruby` - `workdir/build/miniruby`の生成
  - `make encs`     - エンコーディング関連拡張ライブラリの生成
  - `make exts`     - 拡張ライブラリの生成
  - `make ruby`     - `workdir/build/ruby`の生成
  - `make docs`     - rdocの生成

(5) `workdir/build/`以下にビルドしたMRIを`workdir/install/`にインストールする
```
$ make install
```

(6) インストールができていることの確認
```
$ ../install/bin/ruby -v
```

#### `$ history`
```
$ cd workdir/
$ cd ruby
$ autoconf
$ cd ..
$ mkdir build
$ cd build
$ ../ruby/configure --prefix=$PWD/../install --enable-shared --with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --disable-libedit
$ make -j
$ make install
$ ../install/bin/ruby -v
```

## minirubyによるRubyスクリプトの実行
### 手順
1. MRIソースコードを修正する(`workdir/ruby/`)
2. `./miniruby`をビルドする(`workdir/build/`)
    - `$ make miniruby`
3. `$ ./miniruby xxx.rb`を実行(`workdir/build/`)

- `workdir/ruby/test.rb`に実行したいスクリプトを記述する場合、
  手順`2`・`3`はまとめて`$ make run`で実行できる
  - minirubyではなくRubyを使用する場合は`$ make runruby`を実行する

## MRIコースコードの構造
- [MRI のソースコードの構造の紹介](https://github.com/ko1/rubyhackchallenge/blob/master/JA/2_mri_structure.md#mri-%E3%81%AE%E3%82%BD%E3%83%BC%E3%82%B9%E3%82%B3%E3%83%BC%E3%83%89%E3%81%AE%E6%A7%8B%E9%80%A0%E3%81%AE%E7%B4%B9%E4%BB%8B)
