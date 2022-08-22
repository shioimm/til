# Bridge [構造に関するパターン]
- 一連の実装を、それらが利用されるオブジェクトから切り離し、独立したオブジェクトへ分離する

#### 構成要素
- Abstraction
  - オブジェクトのためのインターフェース
  - Implementorを集約する (Implementorを利用する)
- RefinedAbstraction
  - Abstractionから派生した具体的なオブジェクト
- Implementor
  - 実装のためのインターフェース
  - RefinedAbstractionオブジェクトによって実際に利用するConcreteImplementorNを判断する
- ConcreteImplementorN
  - Implementorから派生した具体的な実装を表すオブジェクト

## 参照
- オブジェクト指向のこころ 第10章
