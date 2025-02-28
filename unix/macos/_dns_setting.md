# DNS設定
#### 特定のドメインに問い合わせる際のDNSサーバを指定する
1. `/etc/resolver/`以下に対象のドメイン名と同名のファイルを作成する
2. 当該ファイルに`nameserver <指定したいDNSのIPアドレス>`を記載
3. `ドメイン名`にアクセスするとIPアドレスを指定したDNSサーバに問い合わせを行うようになる

```
$ echo nameserver ***.***.*.* > /etc/resolver/<ドメイン名>.<TLD>
```

## 参照
- [MacのDNSを設定](https://nauthiz.hatenablog.com/entry/20100929/1285778758)
