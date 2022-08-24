# Abstract Factory [生成に関するパターン]
- 特定の状況に適合するオブジェクトが何であるか決定し、それを生成するためのオブジェクトを用意する
  - オブジェクトの生成とオブジェクトの使用を分離する

#### 構成要素
- Client
  - AbstractFactoryにメッセージを送り、必要なProductを得て、Productにメッセージを送る
- AbstractFactory
  - Clientからメッセージを受け取り、Productを生成してClientに返す
- Product
  - Clientからメッセージを受け取る

## 参照
- オブジェクト指向のこころ 第11章
