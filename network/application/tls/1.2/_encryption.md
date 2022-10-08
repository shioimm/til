# TLSにおける暗号化
## 暗号化方式
- TLSにおける暗号化はストリーム暗号化方式、ブロック暗号化方式、AEADのいずれかとなる

#### ストリーム暗号化方式
1. レコードのシーケンス番号、Recordヘッダ、平文データを結合しMACを計算する
2. 計算したMACと平文データとを暗号化することによって暗号文を作る

#### ブロック暗号化方式
1. シーケンス番号、Record ヘッダ、平文データを結合しMACを計算する
2. 暗号化する前のデータの長さが暗号化ブロックの長さの整数倍になるようにパディングを作る
3. 暗号化ブロックと同じ長さのIVを生成する
4. IVを使用し、同じ平文でも違う暗号文になる平文データ、MAC、パディングをCBCモードで暗号化する

#### AEAD
1. 64ビットのnonceを作る
2. 平文データをAEADのアルゴリズムで暗号化する
3. 完全性を検証するための付加的なデータとしてシーケンス番号とRecord ヘッダを暗号化アルゴリズムに渡す
3. nonceと暗号文を一緒に送る

## 暗号処理
#### 疑似乱数生成器 (PRF: pseudorandom function)
- TLS1.2のすべての暗号スイートでは、HMACとSHA256に基づくPRFを利用する

```
// TLS1.2で規定されるPRF
// PRFはP_hash のラッパー (ラベルとシードを結合してP_hashに渡す)
PRF(secret, label, seed) = P_hash(secret, label + seed)

P_hash(secret, seed) = HMAC_hash(secret, A(1) + seed) +
                       HMAC_hash(secret, A(2) + seed) +
                       HMAC_hash(secret, A(3) + seed) + ...

// A関数
A(1) = HMAC_hash(secret, seed)
A(2) = HMAC_hash(secret, A(1))
...
A(i) = HMAC_hash(secret, A(i-1))
```

#### プリマスターシークレット
- マスターシークレットの素材となる乱数データ
- ハンドシェイク時、鍵交換プロトコルによってクライアント - サーバー間で共有される

#### シード
- ClientHelloで得られる`client_random`フィールドの値と
  ServerHelloで得られる`server_random`フィールドの値
- `client_random`と`server_random`は新しいハンドシェイクごとに異なり、
  安全性のためセッション再開時であってもから新しいハンドシェイク取得する必要がある

#### マスターシークレット
- 共通鍵の素材となる乱数データ
- PRFを使ってプリマスターシークレットとシードを処理することで生成される

```
master_secret = PRF(pre_master_secret, "master secret", client_random + server_random)
```

#### 鍵生成
- マスターシークレットとシードからPRFを一回適用することで
  鍵の生成に必要な鍵ブロック`key_block` が生成される

```
key_block = PRF(master_secret, "key expansion", server_random + client_random)
```

- クライアント、サーバーの両者でそれぞれに同じ値の鍵ブロックが生成される
- 生成した鍵ブロックは最大で6つに分割される (ネゴシエーションしたパラメータによって長さは異なる)
  - MAC鍵 * 2 + セッション鍵 * 2 + IV * 2
    - MAC鍵 (クライアント用 / サーバー用) - ハッシュ化に使用する共通鍵、AEADでは不要
    - セッション鍵 (クライアント用 / サーバー用) - アプリケーションデータの暗号化に使用する共通鍵
    - IV (クライアント用 / サーバー用) - ストリーム暗号化方式では不要

#### 暗号スイート
- 認証と鍵交換に必要なアルゴリズムやスキームを決めるパラメータを集めたもの
  - 認証の種類
  - 鍵交換の種類
  - 暗号化アルゴリズム
  - 暗号鍵の長さ
  - 暗号化利用モード (適用可能な場合)
  - MACアルゴリズム (適用可能な場合)
  - PRF (TLS1.2~)
  - Finishedメッセージで使うハッシュ関数 (TLS1.2~)
  - `verify_data`構造体の長さ (TLS1.2~)

```
TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256

// TLS_鍵交換_認証_WITH_アルゴリズム_長さ_暗号化モード_MACまたは擬似乱数生成器
```

## 参照
- プロフェッショナルSSL/TLS
