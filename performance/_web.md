# Webアプリケーション
#### レスポンスを圧縮する
- `Accept-Encoding: gzip`が付与されたリクエストに対してレスポンスボディをgzipで圧縮して返す
  - 圧縮レベルの調整
  - アプリケーションサーバー上でレスポンスを圧縮し、圧縮したレスポンスをプロキシを経由して返す

```
// nginx

// gzipを有効化
gzip on;

// gzip圧縮するMIMEタイプ (画像は既に圧縮済みなので除外)
gzip_types text/css text/javascript application/javascript application/x-javascript application/json;

// gzip圧縮の対象となる最小のファイルサイズ
gzip_min_length 1k;
```

#### Keep-Alive (HTTP/1.1) を有効にする

```
// nginx

location / {
  proxy_http_version 1.1; // HTTP/1.1
  proxy_set_header Connection ""; // Connectionヘッダの指定
  proxy_pass http://app;
}
```

#### 静的ファイルの配信
- 静的ファイルはアプリケーションを介さずにリバースプロキシから配信する
  - アプリケーションが静的ファイルの編集機能を持つ場合、URLも同時に変更することで事故を防止する

```
// nginx
server {
  # ...
  location /image/ {
    root /path/to/images/;
    try_files $uri @app;
  }

  location @app {
    proxy_pass http://app:****;
  }
}

// try_files
// パラメータに指定したファイルパスを前から順番にチェック
// ファイルがあればそのファイルの内容をレスポンスとして返す
// ファイルがなければ最後に指定したURIへリダイレクト
```

- Cache-Controlヘッダを用いて静的ファイルをブラウザにキャッシュさせる

## クラウドサービスにおけるパフォーマンスチューニング
- S3, GCS, CDN
  - Content-Typeはどのように付与されるか
  - gzip圧縮できるコンテンツの場合、gzip圧縮されているか
  - Cache-Controlヘッダの設定は変更可能か

## アプリケーション自身がHTTPクライアントになる場合
- 同一ホストへのコネクションを使い回す (TCP / TLSハンドシェイクの発生を抑止)
- リクエストタイムアウトを適切に設定する
- 利用しているHTTPクライアントライブラリが
  同一ホストへのリクエストに対して許可しているコネクション数を確認する
  (同一ホストに大量のリクエストを送る場合)

## コンテンツデリバリー関連用語
- 帯域 - その回線が時間あたりに転送できる最大データ量 / 「帯域が広い」 = 流せるデータ量が多い
- 通信速度 - その回線が時間あたりに実際転送できたデータ量(スループット)
- レイテンシ(TCP) - ある地点から別の地点までのRTT

### 経路
- ファーストマイル - オリジンがつながっているISPから別のISPに接続するまでの区間
- ミドルマイル - 最初のISPの出口からユーザーが契約しているISPの入り口までの区間
- ラストマイル - ユーザーが契約しているISPからユーザーの自宅やワイヤレス端末までの区間

## パフォーマンス関連用語
- Load time - `onload`イベント(Webページ読み込み時の処理)が呼び出されるまでにかかった時間
  - 全てのCSSとブロッキングしているJavaScriptが読み込まれた後
- First byte - Webサイトから最初のレスポンスを受け取るまでにかかった時間
- Start render - ページの描画を開始した時間
- Visually complete - ページの変更が停止した時間
- Speed index - Webページの各部分が読み込まれる平均時間をms単位で示したWebPagetestの計算式

## 参照
- 達人が教えるWebパフォーマンスチューニング 〜ISUCONから学ぶ高速化の実践
