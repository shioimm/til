# IPv6
#### IPアドレスの拡大
- IPアドレスが128ビットになり、インターネットに適した階層構造になる

#### ルーティングテーブルの集約
- アドレス構造に適するようにIPアドレスの配布を行い、ルーティングテーブルサイズを小さく保つ

#### パフォーマンスの向上
- ヘッダ長固定・ヘッダチェックサムの削除などヘッダの構造を簡素化
- 経路MTU探索を行う (IPv6における最小のMTU定義は1280オクテット)

#### プラグ&プレイ機能の必須化
- DHCPサーバーがない場合でもIPアドレスを自動的に割り当てる

#### 認証機能・暗号化機能
- IPアドレスの偽造に対するセキュリティ機能の提供
- 盗聴防止機能(IPSec)の提供

#### Mobile IPへの対応
- IPv6の拡張機能として定義

## IPv6におけるon-linkとoff-link
- on-link - 同一リンクに接続されていること
- off-link - 同一リンクに接続されていないこと
- IPv6では1つのネットワークインターフェースに複数のIPv6 アドレスが設定できることから、
  IPv6 アドレスとネットワークプレフィックスが異なっていてもon-linkの可能性がある
- 通信相手がon-linkかどうかの判定材料として、Router Advertisementメッセージに含まれる
  Prefix Informationオプションが用いられる
  - Prefix InformationオプションのLフラグが 1 になっている場合
    Prefix Informationオプションが示すプレフィックスをon-linkの判定に利用可能

## 参照
- Linuxプログラミングインターフェース 58章
- Software Design 2021年5月号 ハンズオンTCP/IP
- マスタリングTCP/IP 入門編
- パケットキャプチャの教科書
