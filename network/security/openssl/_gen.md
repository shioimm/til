# 鍵作成
- 作成前に鍵アルゴリズム、鍵の長さ、パスフレーズ (オプション) を決める

#### RSA暗号秘密鍵を作成 (2048ビット)
```
# 2048ビットのRSA暗号の秘密鍵ファイル (fd.key) を作成
$ openssl genrsa 2048 > fd.key

# 作成した秘密鍵 (fd.key) に対応する公開鍵ファイル (fd-public.key) を作成
$ openssl rsa -pubout < fd.key > fd-public.key
```

```
# 作成した公開鍵 (fd-public.key) の構造をフォーマットして出力
# Modules = 割る数n
# Exponent = 冪乗する値e
$ openssl rsa -text -pubin -noout < fd-public.key

# 作成した秘密鍵 (fd.key) の構造をフォーマットして出力
# privateExponent = 秘密鍵d
$ openssl rsa -text -noout < fd.key
```

## 参照
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
- プロフェッショナルSSL/TLS
