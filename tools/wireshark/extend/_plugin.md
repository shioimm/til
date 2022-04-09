# plugin
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
