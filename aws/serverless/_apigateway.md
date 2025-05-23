# Amazon API Gateway
- APIのリクエストパスに従いLambda関数などに接続を行う機能
- APIリクエストを受信する際のみ起動し、APIのルーティングを実行するサーバーレスなルーター/リバースプロキシ
- Web APIの作成、公開、管理を簡単に行うことができる
- APIをデプロイするとエンドポイントURLが払い出され、クライアントからの呼び出しが可能となる
- スロットリングによる流量制御を行う

## Amazon API Gatewayが提供するAPIの種類
#### REST API
- Lambda、HTTPエンドポイント、Mock、AWSサービス、VPCリンクにリクエストを転送できる
- RESTfulなAPIを提供する
- Open APIに準拠した定義ファイルや既存APIのクローンからの作成も可能
- ステートレス通信を行う
- 全てのAPIエンドポイントタイプを選択できる

#### HTTP API
- Lambda、HTTPエンドポイント、AWSサービス、VPCリンクにリクエストを転送でき
- RESTfulなAPIを提供する
- REST APIよりも軽量
- ステートレス通信を行う
- リージョンAPIエンドポイントを利用できる

#### WebSocket API
- Lambda、HTTPエンドポイント、Mock、AWSサービス、VPCリンクにリクエストを転送できる
- WebSocketプロトコルを利用してチャットやダッシュボードといった双方向通信を扱う際に利用する
- ステートフル通信を行う
- リージョンAPIエンドポイントを利用できる

## APIのエンドポイントタイプ
#### エッジ最適化APIエンドポイント
- CloudFrontのエッジロケーションを使用してクライアントを最寄りのPOPへルーティングする

#### プライベートAPIエンドポイント
- パブリックなインターネットから分離してアクセス権限を持ったVPCエンドポイントからのアクセスに限定する

#### リージョンAPIエンドポイント
- 指定したリージョンへデプロイし、同一リージョン内のクライアントにサービスを提供する

## 参照
- [13. Hands-on #6: Bashoutter](https://tomomano.github.io/learn-aws-by-coding/#sec_bashoutter)
- AWSの基本・仕組み・重要用語が全部わかる教科書 13-03
