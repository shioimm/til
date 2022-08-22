# Strategy [振る舞いに関するパターン]
- ビジネスルールやアルゴリズムを、それらが利用されるコンテキストから切り離し独立したオブジェクトへ分離する

#### 構成要素
- Client
- Context
  - ビジネスルールやアルゴリズムを必要とするオブジェクト
  - Clientからメッセージを受け取り、必要な場合はStrategyを呼び出す
  - Contextオブジェクトによって実際に利用するConcreteStrategyNを指定するケースがある
- Strategy
  - Contextからメッセージを受け取り、ConcreteStrategyNへ移譲する
  - Contextオブジェクトによって実際に利用するConcreteStrategyNを判断するケースがある
- ConcreteStrategyN
  - 実際のロジック
  - Strategyからメッセージを受け取る

## 参照
- オブジェクト指向のこころ 第6章
