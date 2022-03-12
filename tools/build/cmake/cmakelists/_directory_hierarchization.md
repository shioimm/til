# 階層化されたプロジェクトにおけるCMakeLists.txt
#### ディレクトリ構造
- pj/
  - lib/
    - include/
      - lib.hpp
    - src/
      - lib.cpp
    - CMakeLists.txt
  - main.cpp
  - CMakeLists.txt

#### pj/lib/CMakeLists.txt

1. CMakeのバージョン`3.1`を指定
2. プロジェクト名`lib`、バージョン`1.0.0`、プロジェクトの説明`This is desc`、
   プロジェクトで使用するプログラム言語`CXX`を指定
3. 静的リンクライブラリ`lib`をビルド対象として宣言
    - `STATIC` - 静的リンクライブラリ
    - `SHARED` - 共有ライブラリ
    - `MODULE` - 動的ロード
4. 作成した`lib`ライブラリのビルドを行う際のプロパティ`cxx_std_11`を指定
    - `PUBLIC` - コマンドの内容を"自分自身"と"自分に依存するターゲット"に反映させる
    - `PRIVATE` - コマンドの内容を"自分自身"にのみ反映させる
    - `INTERFACE` - コマンドの内容を"自分に依存するターゲット"にのみ反映させる
5. 作成した`lib`ライブラリのインクルードディレクトリ`include/`を指定
6. 作成した`lib`ライブラリのプロパティ`VERSION`にバージョン`1.0.0`を設定

```
cmake_minimum_required(VERSION 3.1)
project(lib VERSION 1.0.0 DESCRIPTION "This is desc" LANGUAGES CXX)
add_library(lib STATIC ./src/lib.cpp)
target_compile_features(lib PRIVATE cxx_std_11)
target_include_directories(lib INTERFACE ./include)
set_target_properties(lib PROPERTIES VERSION ${lib_VERSION})
```

#### pj/CMakeLists.txt
1. CMakeのバージョン`3.1`を指定
2. プロジェクト名`pj`、プロジェクトで使用するプログラム言語`CXX`を指定
3. プロジェクトのサブディレクトリとしてlib/を取り込み (lib/CMakeLists.txtを実行)
4. ビルドする実行ファイル名`main_app`とそれを構成するソースファイル`main.cpp`を指定
5. ビルドする実行ファイル`main_app`が`lib`ライブラリに依存していることを宣言

```
cmake_minimum_required(VERSION 3.1)
project(pj CXX)
add_subdirectory(./lib)
add_executable(main_app main.cpp)
target_link_libraries(main_app uftree)
```

## 参照
- [勝手に作るCMake入門 その2 プロジェクトの階層化](https://kamino.hatenablog.com/entry/cmake_tutorial2)
