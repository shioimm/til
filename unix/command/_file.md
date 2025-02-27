# `file(1)`
- ファイルの種別をチェックして表示する

```
$ file FILE_NAME

$ file text.txt
text.txt: UTF-8 Unicode text

$ file /usr/sbin/httpd # (Mach-O - macOSの実行ファイルフォーマット)
/usr/sbin/httpd: Mach-O universal binarywith 2 architectures: [x86_64:Mach-O 64-bit executable x86_64] [arm64e:Mach-O 64-bit executable arm64e]
```

#### ファイル種別のチェック方法
1. スペシャルファイル (デバイスファイル、ディレクトリ、シンボリックリンク) のチェック
2. 圧縮ファイルのチェック
3. .tarファイルのチェック
4. magicデータベースファイル (シグネチャ情報) に基づくチェック
5. 文字コードに基づくテキストファイル種別のチェック
6. それ以外は全てバイナリコードとみなす

## 参照
- Binary Hacks
