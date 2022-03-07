# 内部構成
### Wiresharkの構成要素
- GUI (/ui/qt/) - ホストマシンへGUIを提供する
- Core (/) - 他のブロックをまとめる
- Epan (/epan) - パケット解析エンジンを提供する
  - プロトコルツリー - 個々のパケットの分解情報
  - 各プロトコルディセクタ (/epan/dissectors)
  - ディセクタプラグイン (/plugins) - ディセクタを個別のモジュールとして実装するためのサポート
  - ディスプレイフィルタ (/epan/dfilter)
- Wiretap (/wiretap) - パケットキャプチャ形式ファイルの読み書きのための汎用インタフェースを提供する
- Capture (/) - キャプチャエンジンへのインターフェース
- Dumpcap (/) - キャプチャエンジン (SU権限でネットワークアダプタへのアクセスを行う)

#### パケットキャプチャにおけるWireshark外の構成要素
- libpcap - パケットキャプチャとフィルタリングを行う

## 参照
- [Chapter 6. How Wireshark Works](https://www.wireshark.org/docs/wsdg_html_chunked/ChWorksOverview.html)
