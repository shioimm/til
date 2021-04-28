# MPEG-DASH
## TL;DR
- MPEG Dynamic Adaptive Streaming over HTTP
  - HTTPを使用し適切なビットレートでストリーミングを行う方式
- 動画ストリーミング再生の仕組み(MPEGコンソーシアムによる標準化)
- HTTPを使ったプログレッシブダウンロードで動画再生を行う

### 特徴
- コンテナフォーマットとしてMPEG4 Part 12 / MPEG2-TS / WebMに対応
- コーデックにはH.264 / h.265 / VP8 / VP9が用いられる
- 回線に合わせてすばやくビットレートを切り替える
- マルチアングル、広告に対応

### HLSとの違い
- HLSはブラウザ自身のHLSの`.m3u8`ファイルを解釈して再生する
- MPEG-DASHはデータの解析をJavaScriptが行い、
  動画の再生はブラウザのコーデックをJavaScriptから扱うAPI(HTML5 Media Source Extensions)を利用する
- HLSの動画を再生するプレーヤーも開発されており、サポート環境が充実している

## 参照
- Real World HTTP 第2版
