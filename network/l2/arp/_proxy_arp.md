# 代理ARP (Proxy ARP)
- あるIPアドレスに対するARP要求に対して、ルーターなどのL3デバイスが本来のホストに変わってARP応答する機能
- ルーティングテーブルを使わずにIPパケットを別のセグメントに送りたい場合に利用される
- 送信先ホストはARP応答を返したプロキシのMACアドレスを宛先にしてフレームを送信する
- ARP応答を返したプロキシは本来の送信先のホストへフレームを転送する

## 参照
- [Proxy ARP](https://www.infraexpert.com/study/gateway.htm)
- [Proxy ARP 【プロキシARP】 代理ARP](https://e-words.jp/w/Proxy_ARP.html)
