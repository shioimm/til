# マルチキャスト
- グループ単位でのデータの送受信
- 受信側はマルチキャストグループに参加することにより、
  そのグループに割り当てられたマルチキャストアドレス宛のデータを受け取ることができる
- 送信側はあるマルチキャストグループを指すマルチキャストアドレスをIP パケットの宛先に設定することにより、
  マルチキャストグループに対してデータを送信することができる
- 通信はベストエフォートで行われる
- 受信の順番が送信の順番と一致することは保証されていない

## スコープ
- マルチキャストアドレスによってトラフィックが配送される範囲
- IPv6アドレス体系の一部としてスコープを指定する
- 1 : Interface-Local (インターフェースローカルスコープ) - 単一のインターフェース内
- 2 : Link-Local (リンクローカルスコープ) - 単一のリンク (サブネット) 内
- 3 : Realm-Local (レルムローカルスコープ) - リンクローカルスコー プより広い範囲・ネットワーク体系に依存
- 4 : Admin-Local (アドミンローカルスコープ) - 管理される最小単位でのネットワーク
- 5 : Site-Local (サイトローカルスコープ) - 単一サイト内
- 8 : Organization-Local (組織ローカルスコープ) - 同一組織が保持する複数サイト
- E : Global (グローバルスコープ)

## MLD (Multicast Listener Discovery)
- マルチキャストグループへの参加・離脱を制御するためのプロトコル
- ICMPv6を利用している

## ルータを超えるマルチキャスト
- 複数のネットワークをまたぐ場合はマルチキャストルータによってパケットが転送される
- マルチキャストルータではマルチキャストの次ホップを決定するため、
  マルチキャストグループを宛先とするパケットの配送経路を示す木構造 (マルチキャスト配信ツリー) を構築する

## 参照
- プロフェッショナルIPv6 11