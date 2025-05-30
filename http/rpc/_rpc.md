# RPC
- リモートコンピュータにある機能をホストコンピュータから呼び出し、必要に応じて返り値を得るための仕組み

## 代表的なRPC
### XML-RPC
- 最初に規格化されたRPC
- `Content-Type: text/xml`によって通信を行う
- ステータスコードは常に200になる

### SOAP
- XML-RPCを拡張して作られた規格
- SOAPそのものはデータ表現フォーマットであり、SOAP規格の中にSOAPを利用したSOAP-RPCが定義される
- 可搬性を重視しスキーマを完全装備する方向性で実装され仕様が複雑化した
- ビジネスプロセス実行言語のBPEL、レジストリサービスのUDDIの利用を前提とする

### JSON-RPC
- JSONを使用したRPC
- `Content-Type; application/json`によって通信を行う
- シンプルかつ最大公約数的な仕様が特徴
- ステータスコードは200、204、307、405、415が使用できる

## 参照
- Real World HTTP 第2版
