# Wireshark拡張
### 外部ライブラリの読み込み
#### `wireshark/cmake/modules/Find<PackageName>.cmake`

```txt
```

#### `wireshark/CMakeOptions.txt`
```txt
option(ENABLE_<PackageName>  "<Help Text>" ON)
```

#### `wireshark/CMakeLists.txt`

```txt
ws_find_package(<PackageName> ENABLE_<PackageName> HAVE_<PackageName>)↲
```

## 参照
- [勝手に作るCMake入門 その4 外部ライブラリを利用する](https://kamino.hatenablog.com/entry/cmake_tutorial4)
