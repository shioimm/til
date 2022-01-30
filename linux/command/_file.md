# `file(1)`
- ファイル種別を表示

```
$ file FILE_NAME

$ file text.txt
text.txt: UTF-8 Unicode text

$ file /usr/sbin/httpd # (Mach-O - macOSの実行ファイルフォーマット)
/usr/sbin/httpd: Mach-O universal binarywith 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64e:Mach-O 64-bit executable arm64e]
```
