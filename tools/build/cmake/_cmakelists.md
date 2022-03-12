# CMakeLists.txt

1. CMakeのバージョン`3.1`を指定
2. プロジェクト名`pj`とプロジェクトで使用するプログラム言語`CXX`を指定
3. ビルドする実行ファイル (ターゲット) 名`main_app`とそれを構成するソースファイル`main.cpp`を指定

```
cmake_minimum_required(VERSION 3.1)
project(pj CXX)
add_executable(main_app main.cpp)
```

## 参照
- [勝手に作るCMake入門 その1 基本的な使い方](https://kamino.hatenablog.com/entry/cmake_tutorial1)
