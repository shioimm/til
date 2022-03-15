# Wireshark拡張
#### `wireshark/cmake/modules/Find<PackageName>.cmake`

```txt
find_path(
  <PackageName>_INCLUDE_DIR
  <PackageName>.h
  PATHS "${CMAKE_SOURCE_DIR}/<PackageName>/include"
  NO_DEFAULT_PATH
)

find_library(
  <PackageName>_LIBRARY
  NAMES <PackageName>
  PATHS "${CMAKE_SOURCE_DIR}/<PackageName>/build/host"
  PATH_SUFFIXES lib
  NO_DEFAULT_PATH
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  <PackageName>
  REQUIRED_VARS
  <PackageName>_LIBRARY
  <PackageName>_INCLUDE_DIR
  <PackageName>_VERSION_NUM
  VERSION_VAR
  <PackageName>_VERSION_NUM
)

set(<PackageName>_LIBRARIES "${<PackageName>_LIBRARY}")
set(<PackageName>_INCLUDE_DIRS ${<PackageName>_INCLUDE_DIR} )

mark_as_advanced(<PackageName>_INCLUDE_DIRS <PackageName>_LIBRARIES)
```

#### `wireshark/CMakeOptions.txt`
```txt
option(ENABLE_<PackageName>  "<Help Text>" ON)
```

#### `wireshark/CMakeLists.txt`

```txt
ws_find_package(<PackageName> ENABLE_<PackageName> HAVE_<PackageName>)↲

# ...

target_link_libraries(epan
    # ...
    ${<PackageName>_LIBRARIES}

# ...

target_include_directories(epan
    #
    ${<PackageName>_INCLUDE_DIRS}
```

## 参照
- [勝手に作るCMake入門 その4 外部ライブラリを利用する](https://kamino.hatenablog.com/entry/cmake_tutorial4)
