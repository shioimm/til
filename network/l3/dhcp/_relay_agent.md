# DHCPリレーエージェント
- 複数のEthernetセグメントで構築されるネットワークにおいて、
  複数の異なるセグメントのIPアドレスの割り当てを一台のDHCPサーバーで一元管理・運用する仕組み

#### 動作フロー
1. それぞれのセグメントにDHCPサーバーを置く代わりにDHCPリレーエージェントを設置する
2. 各DHCPリレーエージェントにはDHCPサーバーのIPアドレスを設定する
3. DHCPサーバーにはそれぞれのセグメントごとに配布するIPアドレスの範囲を登録する
4. DHCPリレーエージェントはDHCPクライアントが送信したDHCP要求パケットを受信し、
   ユニキャストパケットにしてDHCPサーバーへ転送する
5. DHCPサーバーはDHCPリレーエージェントから転送されたDHCPパケットを処理し、
   DHCPリレーエージェントへ応答を返す
6. DHCPリレーエージェントはDHCPサーバーから受信した応答をDHCPクライアントへ転送する

## 参照
- Linuxプログラミングインターフェース 58章
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 2.8-9
- Linuxで動かしながら学ぶTCP/IPネットワーク入門 4.5
- コンピュータネットワーク
- マスタリングTCP/IP 入門編
- 実践パケット解析 第3版