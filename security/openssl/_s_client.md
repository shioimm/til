# TLSクライアント
```
# TLSサーバーに接続し接続情報を出力する
$ openssl s_client -connect www.feistyduck.com:443
```

- サーバー証明書の情報
- サーバーが提示したすべての証明書 (配信された順) (所有者 (subject) の情報、発行者 (issuer) の情報)
- サーバー証明書
- TLS接続についての情報

```
# TLS接続への昇格を試す
# 対応プロトコル - smtp、pop3、imap、ftp、xmpp

$ openssl s_client -connect gmail-smtp-in.l.google.com:25 -starttls smtp
```


```
# サーバー証明書を取得

$ echo \
  | openssl s_client -connect www.feistyduck.com:443 2>&1 \
  | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > www.feistyduck.com.crt
```

```
# 対応しているプロトコルを調べる
# 指定可能なオプション -ssl2、-ssl3、-tls1、-tls1_1、-tls1_2

$ openssl s_client -connect www.example.com:443 -tls1_2
```

```
# 対応している暗号スイートを調べる

$ openssl s_client -connect www.feistyduck.com:443 -cipher RC4-SHA
```

```
# セッションの再利用をテストする (対象のサーバーに6回接続する)

$ echo | openssl s_client -connect www.feistyduck.com:443 -reconnect -no_ssl2 2> /dev/null \
  | grep 'New\|Reuse'
```

```
# OCSPによる失効を確認する
# 1. 失効を確認したい証明書を取得する
# 2. その発行元の証明書を取得する
# 3. OCSPレスポンダのURLを特定する
# 4. OCSPリクエストを発行してレスポンスを観察する

$ openssl s_client -connect www.feistyduck.com:443 -showcerts

# 失効を確認したい証明書をfd.crtファイル、
# その発行元の証明書をissuer.crtファイルに格納する

$ openssl ocsp -issuer issuer.crt -cert fd.crt -url \
     http://ocsp.starfieldtech.com/ -CAfile issuer.crt -no_nonce -header Host \
     ocsp.starfieldtech.com
```

```
# OCSPステープリングを調べる

$ echo | openssl s_client -connect www.feistyduck.com:443 -status
```

```
# DHパラメータの強度を見極める

$ openssl-1.0.2 s_client -connnect www.feistyduck.com:443 -cipher kEDH
```

## 参照
- プロフェッショナルSSL/TLS
