# ビルド (macOS)
```
$ git clone https://github.com/wireshark/wireshark
$ cd wireshark
$ tools/macos-setup-brew.sh

# プラグインを追加する場合
$ mkdir plugins/epan/<PluginName>/
$ vim plugins/epan/<PluginName>/packet-<PluginName>.c
$ vim plugins/epan/<PluginName>/CMakeListsCustom.txt # gryphonを参照

$ mkdir build/ && cd build/
$ cmake ..
$ make
```

## 参照
- [2.1. UNIX: Installation and Build Instructions](https://www.wireshark.org/docs/wsdg_html_chunked/ChapterSetup.html#ChSetupUNIX)
