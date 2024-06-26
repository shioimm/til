# 暗号スイートの一覧
```
# 使用しているOpenSSLで対応する暗号スイート一覧
$ openssl ciphers -v 'ALL:COMPLEMENTOFALL' # or 'キーワード'

# 1. 暗号スイートの名前
# 2. 最低限必要なプロトコルのバージョン
# 3. 鍵交換アルゴリズム
# 4. 認証アルゴリズム
# 5. 暗号アルゴリズムと強度
# 6. MAC(完全性)のアルゴリズム
# 7. 輸出暗号スイートの表示
```

#### キーワード (暗号スイートの設定を構成する基本要素) の選択
- よく使われる暗号スイートのグループを選択する場合のキーワード群
- ハッシュ関数のアルゴリズムに基づいて暗号スイートを選択する場合のキーワード群
- 使用する認証方法に基づいて暗号スイートを選択する場合のキーワード群
- 鍵交換アルゴリズムに基づいて暗号スイートを選択する場合のキーワード群
- 暗号化に関する暗号スイートを選択する場合のキーワード群
- その他のキーワード群

## 暗号スイートのリストの構築
```
# リストに追加する新しい暗号スイートのキーワードを渡す (デフォルトでは空)
$ openssl ciphers -v 'キーワード1:キーワード2'
```

#### リストに対する動作を示すキーワード修飾子
- `-` - 削除
- `!` - 永遠に削除
- `+` - 末尾に移動

#### 並べ替え
- `@STRENGTH` - 暗号強度の降順で暗号スイートを並べ替える

## 参照
- [OpenSSL](https:#www.openssl.org/)
- プロフェッショナルSSL/TLS
