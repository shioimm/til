# `tar(1)` / `gzip(1)`
### アーカイブファイルを生成する
```
$ tar cvf アーカイブファイル名.tar アーカイブするファイル名
```

### アーカイブファイルを展開する
```
$ tar xvf アーカイブファイル名.tar
```

### ファイルを圧縮する
```
$ gzip ファイル名
```

### ファイルの圧縮を元に戻す
```
$ gzip -d 圧縮ファイル名.gz
```

### アーカイブファイルを生成して圧縮する
```
$ tar cfvz アーカイブファイル名.tar.gz アーカイブするファイル名
```

### アーカイブファイルの圧縮を元に戻して展開する
```
$ tar xfvz アーカイブファイル名.tar.gz
```
