# サーバープッシュ
## 動作
1. クライアント -> サーバー
    - Requestストリームで`HEADERS`フレームを送信
2. サーバー -> クライアント
    - `HEADERS`フレームを受信する
    - クライアントと同じRequestストリームで`PUSH_PROMISE`フレームを送信
3. サーバー -> クライアント
    - PushストリームでPush IDを送信
    - 当該Pushストリームがどの`PUSH_PROMISE`フレームに紐付くのかを示す
4. サーバー -> クライアント
    - `3`と同じPushストリームでサーバプッシュする`HEADERS`フレームと`DATA`フレームを送信
5. クライアント
    - `HEADERS`フレームと`DATA`フレームを受信
    - 受信したデータを利用すると同時にキャッシュ領域に格納
    - キャッシュ領域に格納されたデータは以降再利用される

#### `PUSH_PROMISE`フレームが格納する情報
- Push ID
  - 次に送るPushストリームと紐付けるためのID
- Encoded Field Section
  - QPACKでエンコードされたリクエストヘッダ
  - 擬似ヘッダを含み、サーバプッシュするレスポンスがどのURLへのリクエストに対するものか記述されている

## クライアントによるサーバープッシュの制御
#### プッシュ数の制限
- クライアントは`PUSH_PROMISE`フレーム受信後、
  Controlストリームで`MAX_PUSH_ID`フレームを送信することで
  サーバーからプッシュされる数を制限することができる

#### サーバープッシュのキャンセル
- クライアントは`PUSH_PROMISE`フレーム受信後、
  Encoded Field Sectionに記述されたURLのキャッシュをすでに持っている場合は
  Controlストリームで`CANCEL_PUSH`フレームを送信することで
  サーバープッシュをキャンセルできる
  - サーバーはサーバープッシュとして送信途中のデータがあっても送信を中止する

## Preload
- HTTP/3のサーバープッシュをサーバーサイドアプリケーションから使用するための仕様
- サーバーサイドアプリケーション(PHP、Rails etc)は生成したレスポンスに
  Linkヘッダを付与することでミドルウェア(nginx etc)に対してサーバープッシュを指示する↲
- ミドルウェアは指定されたリソースをサーバープッシュする

```
Link: </app/style.css>; rel=preload; as=style
Link: </app/script.js>; rel=preload; as=script
```

## 参照
- Real World HTTP 第2版
- WEB+DB PRESS Vol.123 HTTP/3入門
