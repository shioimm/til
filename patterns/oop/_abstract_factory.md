# Abstract Factory [生成に関するパターン]
- 特定の状況に適合するオブジェクトが何であるか決定し、それを生成するためのオブジェクトを用意する
  - オブジェクトの生成とオブジェクトの使用を分離する

#### 構成要素
- Client
  - AbstractFactoryにメッセージを送り、ProductNを受け取る
  - ProductNにメッセージを送る
- AbstractFactory
  - Clientからメッセージを受け取り、実際に利用するConcreteFactoryNを判断してConcreteFactoryNへ移譲する
  - ConcreteFactoryNによって生成されたProductNをClientへ返す
- ConcreteFactoryN
  - ProductNを生成する
- ProductN
  - Clientからメッセージを受け取る

## 参照
- オブジェクト指向のこころ 第11章
