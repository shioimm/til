# plugin
#### `wireshark/CMakeLists.txt`

```txt
ws_find_package(<PackageName> ENABLE_<PackageName> HAVE_<PackageName>)
```

#### plugins/epan/`<PluginName>`/CMakeLists.txt

```txt
target_link_libraries(<PluginName> epan ${<PackageName>_LIBRARIES})
target_include_directories(<PluginName> PRIVATE ${<PackageName>_INCLUDE_DIRS})
```
