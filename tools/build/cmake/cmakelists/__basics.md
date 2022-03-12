# CMakeLists.txt
#### ディレクトリ構造
- pj
  - CMakeLists.txt
  - prog.cpp

#### pj/CMakeLists.txt
1. CMakeのバージョン`3.1`を指定
2. プロジェクト名`pj`とプロジェクトで使用するプログラム言語`CXX`を指定
3. ソースファイル`prog.cpp`をコンパイルして実行ファイル`prog`を作成

```
cmake_minimum_required(VERSION 3.1)
project(pj CXX)
add_executable(prog prog.cpp)
```

## 参照
- [勝手に作るCMake入門 その1 基本的な使い方](https://kamino.hatenablog.com/entry/cmake_tutorial1)
