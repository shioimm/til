# WebRTC
- 参照: [WebRTC](https://webrtc.org/)
- 参照: [WebRTC API](https://developer.mozilla.org/ja/docs/Web/API/WebRTC_API)
- 参照: [WebRTC コトハジメ](https://gist.github.com/voluntas/67e5a26915751226fdcf)
- P2Pを利用しブラウザ間でのリアルタイム通信を可能にするオープンソースプロジェクト
  - 任意のデータの交換・オーディオ／ビデオストリームの送受信
- プラグインやサードパーティソフトウェアのインストールが不要
- W3C/IETFで標準化が進行中

## 技術的側面
- 相互に関係するAPI群とプロトコル群から構成される
- 通信プロトコルとしてUDPを使用
  - 大量のデータを高速に送ることができる
  - エラーハンドリングや再送処理を行わない
- 通信はデフォルトで暗号化されている
  - DTLS(データグラム向けのTLS)を採用
- NAT越えを実現する仕組みが含まれる
  - STUN/TURNおよびSTUN/TURNを組み合わせたICEを採用
