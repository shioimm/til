# mainコンテキスト(全体の設定)
```
# workerプロセスの実行権限ユーザー名
user nginx;

# workerのプロセス数
# autoに設定するとコア数と同数のプロセスを起動する
worker_processes 1;

# エラーログの出力先とログレベル
error_log /var/log/nginx/error.log warn;

# masterプロセスのプロセスIDを保存するファイル
pid /var/run/nginx.pid;
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
