# バーチャルホストの設定
- 参照: [プログラミングビギナーNekoteniがあなたに贈る！NginxでVirtual Hostの巻](https://blog.goo.ne.jp/moonycat/e/b09ff732b80e098dea9c627bc0b64eda)

## ディレクトリ構成
```
# Debian

/
|
|- etc/ 設定ファイル
|    |- init.d/
| 　    　|- nginx/ Nginxの実行ファイル
|              |- sites-available/
|              |    |- バーチャルホスト名
|              |       $ sudo vim /etc/nginx/sites-available/バーチャルホスト名↲
|              |
|              |- sites-available/
|                   |- バーチャルホスト名
|                      $ sudo ln -s /etc/nginx/sites-available/バーチャルホスト名 /etc/nginx/sites-enabled/バーチャルホスト名
|
|- home/
|    |- xxxx/ Virtual Hostのデータを格納するディレクトリ
|  　     |- public_html/
|  　 　       |- バーチャルホスト名/
|                 $ sudo mkdir -p /home/demo/public_html/バーチャルホスト名/{public,private,log,backup}
|                   |
|  　 　　          |- public/
|                   |    |- index.html
|  　 　　          |- private/
|  　 　　          |- log/
|  　 　　          |- backup/
|
|- usr/ プログラムやカーネルソース
|    |- share/
|  　　   |- nginx/
|              |- index.html デフォルトのウェルカムページ
```
