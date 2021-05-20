# 自己署名証明書

```
$ openssl genrsa 2024 > server.key
    openssl genrsa 2024 > server.key
    Generating RSA private key, 2024 bit long modulus
    .................+++
    ................................+++
    e is 65537 (0x10001)

$ openssl req -new -key server.key > server.csr
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) []:
    State or Province Name (full name) []:
    Locality Name (eg, city) []:
    Organization Name (eg, company) []:
    Organizational Unit Name (eg, section) []:
    Common Name (eg, fully qualified host name) []:ssl.localhost
    Email Address []:

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:

$ openssl x509 -req -days 3650 -signkey server.key < server.csr > server.crt
    Signature ok
    subject=/CN=sample_cert
    Getting Private key
```

1. 秘密鍵の作成(server.key)
    - `genrsa` - RSA秘密鍵
    - `2024` - 2048ビット鍵長
2. 証明書署名要求(CSR)の作成(server.csr)
    - Common Name(コモンネーム) - `ssl.localhost`
3. サーバー証明書の作成(server.crt)
    - `openssl x509` - 自己署名
    - `-days 3650` - 3650日
