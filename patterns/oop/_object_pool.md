# Object Pool [生成に関するパターン]
- 一連のオブジェクト群と、
  各オブジェクトの作成と再利用、削除と再作成 (エラー時) を管理する役割を担うオブジェクトを分離する

#### 構成要素
- Client
  - ReusablePoolにReusableを要求し、ReusablePoolから取得したReusableにメッセージを送る
- ReusablePool
  - Reusableを作成する
  - Clientからメッセージを受け取り、Reusableを払い出してClientに返す
  - 利用された後のReusableをプールに戻す
  - Reusableのエラー時、Reusableを削除し、新しいReusableを作成する
- Reusable
  - Clientからメッセージを受け取る

## 参照
- オブジェクト指向のこころ 第22章
