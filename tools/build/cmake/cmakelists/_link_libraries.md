# 外部ライブラリの利用
```
# 外部ライブラリ読み込みの基本構文

# 1. 外部ライブラリlibxのライブラリディレクトリlibx/lib/を指定
link_directories("libx/lib")

add_executable(prog prog.cpp)

# 2. 外部ライブラリlibxのインクルードディレクトリlibx/include/を指定
target_include_directories(prog PRIVATE "libx/include")

# 3. 実行ファイル`prog`の作成時に外部ライブラリ`libx`をリンク
target_link_libraries(prog libx)
```

---

#### 外部ライブラリLibXがConfigLibX.cmakeを用意している場合の例
1. CMakeのバージョン`3.1`を指定
2. プロジェクト名`pj`とプロジェクトで使用するプログラム言語`CXX`を指定
3. CMakeスクリプト`ConfigLibX.cmake`を探し出し、それを実行する (-> LibXのビルド・リンクを実行)
4. ソースファイル`prog.cpp`をコンパイルして実行ファイル`prog`を作成
5. 実行ファイル`prog`の作成時に外部ライブラリ`libx`をリンク

```
cmake_minimum_required(VERSION 3.1)
project(pj CXX)
find_package(LibX REQUIRED)
add_executable(prog prog.cpp)
target_link_libraries(prog ${LIBX_LIBRARIES})
```

## 参照
- [勝手に作るCMake入門 その4 外部ライブラリを利用する](https://kamino.hatenablog.com/entry/cmake_tutorial4)
