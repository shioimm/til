# pkg-config
- `*.pc`ファイルに記録された情報を元にビルド時に必要な文字列を返す
  - `*.pc`ファイルはデフォルトで`/usr/lib/pkgconfig/`以下に配置される
  - `*.pc`ファイルの位置は環境変数`PKG_CONFIG_PATH`によって示す

```
$ gcc -o xxxx xxxx.c `pkg-config --libs --cflags glib-2.0`
```

## 参照
- [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/)
