# Rack::Chunked
- 引用: [rack/lib/rack/chunked.rb](https://github.com/rack/rack/blob/master/lib/rack/chunked.rb)

## 概要
- チャンク化されたエンコーディングを使用してストリーミングレスポンスを行うためのミドルウェア
- レスポンスヘッダにContent-Lengthが含まれていない場合、
  レスポンスボディにチャンク化された転送エンコーディングを適用する
- Trailerレスポンスヘッダをサポートしており、
  チャンク化されたエンコーディングで末尾のヘッダを使用できるようにする
- 使用時には+trailers+メソッドをサポートするレスポンスボディを手動で指定する必要がある

## `Rack::Chunked#call`
- Rackアプリケーションがボディを持つはずのレスポンスを返し、
  かつContent-LengthヘッダまたはTransfer-Encodingヘッダがない場合、
  チャンク化されたTransfer-Encodingを使用するようにレスポンスを修正する
