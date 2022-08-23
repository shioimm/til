# Adapter [構造に関するパターン]
- 変更できない既存のオブジェクトを、目的に適う特定のインターフェースへ適合させる
  - Object Adapter - オブジェクトが他のオブジェクトを包含する
  - Class Adapter - 多重継承を利用してAdapterパターンを実現する

#### 構成要素
- Client
- Adapter
  - Clientが要求するインターフェースを持つ
  - Clientからメッセージを受け取り、Adapteeへ委譲する
- Adaptee
  - 実装をもつ既存のオブジェクト
  - Adapterからメッセージを受け取る

## 参照
- オブジェクト指向のこころ 第7章
