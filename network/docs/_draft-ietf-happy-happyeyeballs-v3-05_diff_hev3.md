# draft-03 -> draft-05 差分 (仕様と項目番号の変更のみ)
https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/

## 項目番号の変更
- (03) 4.4 Handling Multiple DNS Server Addresses ->  (05) 削除 (05の4.4は Handling Expired Answers に差し替え)
- (03) 8 Supporting IPv6-Mostly and IPv6-Only Networks -> (05) 8 Handling NAT64 Networks
- (03) 8.1 IPv4 Address Literals -> (05) 削除 (内容は8.3に統合)
- (03) 8.2 Discovering and Utilizing PREF64 -> (05) 8.1 Discovering PREF64
- (03) 8.3 Supporting DNS64 -> (05) 削除
- (03) 8.4 Hostnames with Broken AAAA Records -> (05) 削除
- (03) 8.5 Virtual Private Networks -> (05) 削除 (9 Multiple Networks に置き換え)
- (03) なし -> (05) 8.2 Handling Synthesized Answers (新規)
- (03) なし -> (05) 8.3 Synthesizing IPv6 Addresses During Connection Establishment (新規)
- (03) なし -> (05) 9 Multiple Networks (新規)
- (03) 9 Summary of Configurable Values -> (05) 10 (Configurable Values)
- (03) 10 Limitations (10.1 / 10.2 / 10.3) -> (05) 11 (11.1 / 11.2 / 11.3)
- (03) 11 Security Considerations -> (05) 12
- (03) 12 IANA Considerations -> (05) 13
- (03) 13 References (13.1 / 13.2) -> (05) 14 (14.1 / 14.2)

## 仕様の変更
### 4.1 Sending DNS Queries
- 「接続性」の判定単位が、PvD (Provisioning Domain) 単位になった
- [MUST] IPv6接続性がある場合、AAAAクエリを含める
- [MUST] IPv4接続性がある場合、Aクエリを含める
- [MUST] NAT64 prefixを検出した場合、IPv6-onlyでもAクエリを含める
  - 03: IPv6のみのネットワークでは「AAAA / A両方、またはAAAAのみ」とネットワーク構成依存
- スタブリゾルバの扱いは [RFC10001] 4.3 を参照 (クエリ送信順序はスタブリゾルバ次第で実現できない場合がある)

### 4.2 Handling DNS Answers Asynchronously
- Resolution Delayの推奨値: 50ms -> 25ms

### 4.4 (03) Handling Multiple DNS Server Addresses -> (05) Handling Expired Answers
- 削除: DNSサーバが複数ある場合のIPv6優先 (SHOULD) と、DNSサーバ数に上限を設けない (SHOULD NOT)
- 追加: DNS応答の有効期限が切れても、進行中の接続試行はキャンセルしない
- 追加: 接続が未成功なら、新しいクエリを発行してもよい (MAY)
- 追加: 試行未開始で、解決済みリストにも存在しなくなったエンドポイントは削除する
- 追加: optimistic DNS ([OPTIMISTIC-DNS]) への言及

### 5.3 Sorting Destination Addresses Within Groups
- 履歴データの分離境界: ネットワークインターフェース -> PvD
  - [MUST NOT] 異なるPvD間で履歴データを使用しない
- 削除: ネットワーク変更時に履歴データを消去する (SHOULD)
- 削除: 以前接続したネットワークを確実に識別できる場合の履歴データ再利用 (MAY)
  - PvDに関する処理は9章へ移動

### 6 Connection Attempts
- 追加 [MAY]: 接続成功後も、進行中でより優先度の高い試行をバックグラウンドで継続してよい
- 追加 [MUST NOT]: 接続試行間で鍵共有 (key share) を再利用しない ([RFC9846] 4.2.8)
- 追加 [MUST NOT]: 接続試行間でQUIC Initialパケットのコピーや Connection ID を再利用しない ([RFC9000] 9.5)
- 追加: サービスグループの意図は「最も優先されるサービスを厳密に優先すること」であると明記
- 追加 [MAY]: 2つのパケットを同時に送らないよう、ジッタやペーシングを適用してよい
- 追加 [MAY]: Connection Attempt Delay Multiplier (接続試行ごとに遅延を増加させる)
  - 例: 基準50ms・倍率2 -> 0, 50, 150, 350, 750ms
- 追加: 同一ホストへの複数のHappy Eyeballs手続きを調整なしに並行実行するとバーストが生じる
  - 接続の共有・コアレス、またはペーシングの調整で緩和する

### 6.1 Determining successful connection establishment
- SVCB-reliant (またはSVCB-optionalでSVCB依存に切り替わりうる) クライアントは、
  暗号ハンドシェイク前にSVCBレコードを待つ [MUST] (03と同趣旨で、文言のみ整理)

### 6.3 Dropping or Pending Connection Attempts
- 追加 [MAY]: TCPは、解決済みA / AAAAアドレスに対してハンドシェイクのみ投機的に開始してよい (TLS ClientHelloは保留)
  - 選ばれたエンドポイントと一致しなければ、ClientHelloを送らずにそのTCP接続を閉じる [SHOULD]
- 追加: QUICはClientHelloがInitialパケットに含まれるため、SVCB応答までQUICパケットをすべて保留する
- 追加 [MAY]: プライバシー要件が厳しいクライアントは、TCPハンドシェイクもSVCB応答まで保留してよい

### 7 DNS Answer Changes During Happy Eyeballs Connection Setup
- 追加 [MAY]: Connection Attempt Delayタイマ実行中にDNS応答が変化したら、タイマを再スケジュールしてよい
  - DNS更新だけでは根拠にならないが、更新前に開始した試行が想定時間内に進展していなければタイマを早く発火させてよい
  - Minimum Connection Attempt Delayの制約を受ける

### 8 Handling NAT64 Networks
- 削除: 464XLATに関する記述
- 削除: IPv6-mostly / IPv6-onlyネットワークの簡易検出方法
- 削除: DNS64を仮定する手順 (03の8.3)
- 削除: broken AAAA 対応 (03の8.4)
  - Last Resort Local Synthesis Delay (推奨2秒) も削除
- 8.1: PREF64の取得元は、RAのPREF64オプションと `ipv4only.arpa` へのDNSクエリ
  - RAにPREF64がない場合は [SHOULD] DNSクエリを送る
- 8.2 (新規) [MUST] 合成されたアドレスは、グループ化・ソート・接続の前にIPv4アドレスへ逆合成 (de-synthesize) する
- 8.2 (新規) [MUST] PREF64を認識しているクライアントは、AAAA応答が合成アドレスでないか確認する
- 8.3 (新規) [MUST] 「適用されるIPv4ルートが存在しない」場合、PREF64でIPv4アドレスをIPv6アドレスに合成する
  - 対象: Aレコード、IPv4アドレスヒント、逆合成したアドレス、アプリケーションが渡したIPv4リテラル

### 9 Multiple Networks (新規)
- [MUST] アルゴリズムを導く情報をPvDごとに分離する
- PvD間で共有してはならない情報: DNS応答、NAT64 prefix、履歴データ (RTT、過去に使用したアドレスなど)
- [SHOULD] PvDが変わったらPvDごとのキャッシュを消去する
  - [MAY] 以前のPvDを確実に識別できるなら、そのキャッシュを保持して再利用してよい
- スプリットホライズンVPN: VPNのDNSサーバとルートの集合を1つのPvDとして扱い、VPNの接続・切断をPvD変更として扱う
  - 03の8.5 (企業リゾルバでAレコードを解決しローカルでIPv6合成する) に代わる記述

### 10 Configurable Values (03の9)
- Resolution Delay: 50ms -> 25ms
- 追加: Connection Attempt Delay Multiplier (推奨値1、一定の遅延)
- 削除: Last Resort Local Synthesis Delay
- 変更なし: Connection Attempt Delay 250ms
  - Minimum 100ms (10ms未満は MUST NOT) / Maximum 2秒 / Preferred Address Family Count 1

### 11 Limitations (03の10)
- 11.1: IPv6限定で起きるとする記述が「IPv6トラフィックでより起きやすいかもしれない」程度に弱まった
- 11.1: [RFC8900] を参照に追加

### 12 Security Considerations (03の11)
- 追加: ECHダウングレード
  - 経路上の攻撃者がSVCB / HTTPS応答だけを遅延・破棄し、クライアントがSVCBを待たずに進むと、ECHが省略される
  - 緩和策: DNSが保護されている場合はSVCB / HTTPS応答を待つ、保護された名前解決が失敗したら試行を中止する (6.3)
- 追加: 投機的TCPハンドシェイクによって、オリジンのIPアドレスへの接触が観測されうる
- 変更なし: [MUST NOT] 保護されたDNSを使う場合、有効なHTTPS応答を受信するまで
  TCPハンドシェイク完了後に暗号化されていないデータを送らない

### 13 IANA Considerations
- 変更なし

## 参照の変更 (14 References)
- 正式RFC化: [ECH] -> RFC 9849、[SVCB-ECH] -> RFC 9848
- ドラフト版の更新: [I-D.ietf-tls-key-share-prediction] draft-03 -> draft-05、[V6-MOSTLY] draft-04 -> draft-12
- 追加 (Normative): [NAT64]、[PREF64]、[RFC3927]、[RFC4291]、[RFC6147]、[RFC9460]
- 追加 (Informative): [DNS64]、[OPTIMISTIC-DNS]、[PvD] (RFC 7556)、[QUIC]、[RFC6877]、[RFC8900]、[RFC9461]、[RFC9704]、[RFC9846]、[RFC10001]
