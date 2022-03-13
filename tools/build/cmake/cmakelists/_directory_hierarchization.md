# 階層化されたプロジェクトにおけるCMakeLists.txt
#### ディレクトリ構造
- pj/
  - libx/
    - include/
      - libx.hpp
    - src/
      - libx.cpp
    - CMakeLists.txt
  - prog.cpp
  - CMakeLists.txt

#### pj/libx/CMakeLists.txt

1. CMakeのバージョン`3.1`を指定
2. プロジェクト名`libx`、バージョン`1.0.0`、プロジェクトの説明`This is desc`、
   プロジェクトで使用するプログラム言語`CXX`を指定
3. `libx.cpp`をコンパイルし、静的リンクライブラリ`liblibx.a`を作成
    - `STATIC` - 静的リンクライブラリ
    - `SHARED` - 共有ライブラリ
    - `MODULE` - 動的ロード
4. ライブラリ`libx`のビルドを行う際のプロパティ`cxx_std_11`を指定
    - `PUBLIC` - コマンドの内容を"自分自身"と"自分に依存するターゲット"に反映させる
    - `PRIVATE` - コマンドの内容を"自分自身"にのみ反映させる
    - `INTERFACE` - コマンドの内容を"自分に依存するターゲット"にのみ反映させる
5. ライブラリ`libx`のインクルードディレクトリ`include/`を指定
6. ライブラリ`libx`のプロパティ`VERSION`にバージョン`1.0.0`を設定

```
cmake_minimum_required(VERSION 3.1)
project(libx VERSION 1.0.0 DESCRIPTION "This is desc" LANGUAGES CXX)
add_libxrary(libx STATIC ./src/libx.cpp)
target_compile_features(libx PRIVATE cxx_std_11)
target_include_directories(libx INTERFACE ./include)
set_target_properties(libx PROPERTIES VERSION ${libx_VERSION})
```

#### pj/CMakeLists.txt
1. CMakeのバージョン`3.1`を指定
2. プロジェクト名`pj`、プロジェクトで使用するプログラム言語`CXX`を指定
3. プロジェクトのサブディレクトリとしてlibx/を取り込み (libx/CMakeLists.txtを実行)
4. ソースファイル`prog.cpp`をコンパイルして実行ファイル`prog`を作成
5. 実行ファイル`prog`の作成時にライブラリ`libx`をリンク

```
cmake_minimum_required(VERSION 3.1)
project(pj CXX)
add_subdirectory(./libx)
add_executable(prog prog.cpp)
target_link_libxraries(prog libx)
```

## 参照
- [勝手に作るCMake入門 その2 プロジェクトの階層化](https://kamino.hatenablog.com/entry/cmake_tutorial2)
