# eventsコンテキスト
```
# イベントループ関連の設定

events {
  # 一つのworkerプロセスが同時に受け付けられる接続数
  worker_connections 1024;
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
