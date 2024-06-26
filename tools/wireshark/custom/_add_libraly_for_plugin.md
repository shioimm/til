# ライブラリを追加 (プラグインで利用)
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

#### `wireshark/CMakeLists.txt`

```txt
ws_find_package(<PackageName> ENABLE_<PackageName> HAVE_<PackageName>)
```

#### `wireshark/CMakeOptions.txt`

```txt
option(ENABLE_<PackageName>  "<Help Text>" ON)
```

#### `wireshark/cmakeconfig.h.in`

```txt
#cmakedefine HAVE_<PackageName> 1
```

#### `plugins/epan/<PluginName>/CMakeLists.txt`

```txt
target_link_libraries(<PluginName> epan ${<PackageName>_LIBRARIES})
target_include_directories(<PluginName> PRIVATE ${<PackageName>_INCLUDE_DIRS})
```
