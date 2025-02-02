# Windows環境での開発
- MSYS2 (Minimal System 2) - Windows上でUnixライクな環境を提供するツールセット
- MinGW (Minimalist GNU for Windows) - Windows上でネイティブなWindowsバイナリをコンパイルできるGCC環境
  - mingw64 - `x86_64`Windows用コンパイル環境 (`mingw-w64-x86_64-*`パッケージ使用)
  - mingw32 - `x86_32`Windows用コンパイル環境 (`mingw-w64-i686-*`パッケージ使用)
  - ucrt64 - UCRTベースの`x86_64`Windows用コンパイル環境 (`mingw-w64-ucrt-x86_64-*`パッケージ使用)
    - UCRT - Universal C Runtime
- pacman - MSYS2で使用されるパッケージ管理ツール

#### ビルド (正しいかどうかはわからない...)
MSYS2公式サイトから`msys2-x86_64-xxxx.exe`をダウンロードしてインストールしMSYS2 URCT64を起動しておく

```
# BASERUBYを用意
$ pacman -S mingw-w64-ucrt-x86_64-ruby

# autoconfを用意
$ pacman -S autoconf

$ git clone http://github,com/shioimm/ruby.git
$ cd ruby
$ autoconf

$ cd ../

# config.guess / config.subがないので取得
$ wget http://git.savannah.gnu.org/cgit/config.git/plain/config.guess
$ wget http://git.savannah.gnu.org/cgit/config.git/plain/config.sub
$ chmod +x config.guess config.sub
$ mv config.guess config.sub tool/

$ mkdir build
$ cd build

$ ../ruby/configure --prefix=$PWD/../install --enable-shared --disable-install-doc --with-opt-dir=/ucrt64
$ make -j
$ make install
```
