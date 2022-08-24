# Decorator [構造に関するパターン]
- 既存のコンポーネントに対して新たな機能を付加する
- Decoratorは既存のコンポーネントが持つ機能の前後に新たな機能を動的に付加する

#### 構成要素
- Client
  - Componentにメッセージを送る
- Component
  - Decoratorを集約する
  - DecoratorとConcreteComponentをサブクラスとして持つ
  - Clientからメッセージを受け取り、Decoratorによって機能を付加したConcreteComponentを返す
- ConcreteComponent
  - Decoratorに渡され、Decoratorによって機能が付加される
- Decorator
  - ConcreteComponentを受け取り、
    機能を付加してConcreteComponentと同じインターフェース・型を持つオブジェクトを返す

## 参照
- オブジェクト指向のこころ 第17章
