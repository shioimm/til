# dyld: Library not loaded: /usr/local/opt/icu4c/lib/libicui18n.xx.dylib
```
$ brew reinstall postgresql # PGをupgrade -> 14系が再インストール
$ brew cleanup # 不要なファイルを削除

$ brew unlink postgresql
$ brew link   postgresql@13 # バージョンを13系へ切り替え

$ pg_ctl -D /usr/local/var/postgres start

dyld: Library not loaded: /usr/local/opt/icu4c/lib/libicui18n.69.dylib
  Referenced from: /usr/local/Cellar/postgresql@13/13.6/bin/postgres
  Reason: image not found
no data was returned by command ""/usr/local/Cellar/postgresql@13/13.6/bin/postgres" -V"
The program "postgres" is needed by pg_ctl but was not found in the
same directory as "/usr/local/Cellar/postgresql@13/13.6/bin/pg_ctl".
Check your installation.

$ brew info icu4c

icu4c: stable 70.1 (bottled) [keg-only]
C/C++ and Java libraries for Unicode and globalization
http://site.icu-project.org/home
/usr/local/Cellar/icu4c/70.1 (261 files, 74.4MB)
  Poured from bottle on 2022-03-08 at 18:24:32
```

- 14系を再インストール後、不要なファイルを削除したため
  13系が使用しているバージョンのlibicui18nのダイナミックライブラリが削除されている

```
$ brew reinstall postgresql@13 # 13系を再インストール
$ pg_ctl -D /usr/local/var/postgres start

waiting for server to start...

 done
server started
```
