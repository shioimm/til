# Amazon SNS (Simple Notification Service)
- マネージド型のメッセージ配信サービス
- Pub-Subモデルによる非同期なメッセージ配信を実現できる
  - Publisher (発行者) とSubscriber (購読者) の間をTopicによって仲介し、両者を疎に結合する
  - Publisherが生成したメッセージがTopicに送信されるとただちにSubscriberにメッセージが配信される
  - メッセージの配信に失敗した場合、Subscriberの種類に応じたポリシーを利用してリトライされる
  - KMS (Key Management Service) によってTopic内に保持するメッセージを暗号化できる

## 構成要素
#### Publisher
- メッセージの発行元
  - EC2、Fargate、Lambda、CloudWatch Function、S3
- Topicに対してメッセージを発行する

#### Subscriber
- メッセージを受信するエンドポイント
  - Lambda、SQS、Kinesis Data Firehose、HTTP/S、Eメール・SMS、モバイル (プッシュ通知)
- 興味のあるTopicを予め購読しておく
- 購読中のTopicにメッセージが格納されるとメッセージを受信する

#### Topic
- 通信チャネルとして機能する論理的なエンドポイント
- Publisherから発行されたメッセージを格納し、Subscriberにメッセージを配信する

## Topicの種類

|              | スタンダードTopic                    | FIFO Topic                                       |
| -            | -                                    | -                                                |
| 配信順序     | 順序性が保証されない                 | 同一メッセージグループIDにおいて順序が保証される |
| 配信方式     | メッセージの重複の有無に関わらず配信 | 重複を排除して1回のみ配信                        |
| スループット | ほぼ無制限にメッセージを処理         | 最大300件/秒のメッセージを処理                   |

#### 重複排除の保証 (FIFO Topic)
- 特定の重複排除IDを持つメッセージが正常に発行されて以降5分間は同一IDを持つメッセージの配信を行わない
  - コンテンツベースのメッセージ重複排除を有効化する方法
    - メッセージ本文の内容を元にSHA-256でハッシュ値を計算し、重複排除IDとする
  - 利用者が発行するメッセージに独自の重複排除IDを設定する方法

## 参照
- AWSの基本・仕組み・重要用語が全部わかる教科書 07-01
