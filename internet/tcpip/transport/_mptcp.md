# MultiPath TCP
- アプリケーションには従来のTCPインターフェースを提供し、
  実際には複数のIPアドレス/インターフェースを同時に使用することで
  複数のサブフローにデータを分散させるTCPの改良(RFC 6824)
  - リソースの有効活用、スループット向上、障害発生時のスムーズな対応

## Linux実装
- [multipath-tcp/mptcp](https://github.com/multipath-tcp/mptcp)
- [MultiPath TCP - Linux Kernel implementation](http://multipath-tcp.org/)
- ノード同士がMPTCP対応のLinuxカーネルである場合、アプリケーション層を変更することなく利用が可能

## 参照
- [Multipath TCP(MPTCP)](https://blog.bitmeister.jp/?p=4340)
- [Linux 5.6 から Multipath TCPが使える](https://asnokaze.hatenablog.com/entry/2020/09/25/004932)
