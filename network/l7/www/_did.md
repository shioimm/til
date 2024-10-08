# W3C DID: Decentralized Identifiers (分散型識別子)
#### 分散型識別子
- アイデンティティを持つ主体が自身のIDを管理できるようにする機構

### 構成
```
did:example:123456789abcdefghi

* did: スキーム
* example: 実装方法を示す文字列
* 123456789abcdefghi: 実装方法に応じて作成される一意の文字列
```

### DID文書
- 関連情報へのエンドポイント、認証情報、公開鍵情報などをまとめた文書
- 第三者が主体の関連情報を参照したいとき、
  主体が相手にDID文書へのアクセスを許可することにより、
  主体は参照を許した関連情報だけを相手に公開することができ、
  相手は関連情報の署名や公開鍵などを用いて関連情報が正しいことを確認できる

## 参照
- [Decentralized Identifiers (DIDs)](https://www.w3.org/TR/2022/REC-did-core-20220719/)
