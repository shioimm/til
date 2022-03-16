# Epan
#### `wireshark/CMakeOptions.txt`

```txt
option(ENABLE_<PackageName>  "<Help Text>" ON)
```

#### `wireshark/CMakeLists.txt`

```txt
ws_find_package(<PackageName> ENABLE_<PackageName> HAVE_<PackageName>)
```

#### cmakeconfig.h.in

```txt
#cmakedefine HAVE_MRUBY 1
```

#### `wireshark/epan/CMakeLists.txt`

```txt
target_link_libraries(epan
    # ...
    ${<PackageName>_LIBRARIES}

# ...

target_include_directories(epan
    #
    ${<PackageName>_INCLUDE_DIRS}
```

#### epan/ws`<PackageName>`/CMakeLists.txt
```txt
set(
  WS<PackageName>_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/sample.c
)

source_group(ws<PackageName> FILES ${WS<PackageName>_FILES})

set_source_files_properties(
  ${WS<PackageName>_FILES}
  PROPERTIES
    COMPILE_FLAGS "${WERROR_COMMON_FLAGS}"
)

add_library(ws<PackageName> OBJECT
  ${WS<PackageName>_FILES}
)

target_include_directories(ws<PackageName>
  SYSTEM PRIVATE
    ${<PackageName>_INCLUDE_DIRS}
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

checkapi(
  NAME
    ws<PackageName>
  SOURCES
    ${WS<PackageName>_FILES}
)
```
