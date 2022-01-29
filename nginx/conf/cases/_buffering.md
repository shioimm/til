# バッファリング
```
server {
  location / {
    proxy_buffering            on;    # バッファリングするかどうか
    proxy_buffer_size          4k;    # レスポンスの先頭部分に使われるメモリ上のバッファサイズ
    proxy_buffers              8 4k;  # proxy_buffer_sizeの次に使われるメモリ上のバッファ数・サイズ
    proxy_max_temp_file_size   1024m; # tempファイルに保存されるバッファサイズ
    proxy_temp_file_write_size 8k;    # tempファイルのバッファに書き出されるデータサイズ
    proxy_busy_buffer_size     8k;    # レスポンス送信中の状態にできるバッファサイズ
  }
}
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
