# hping3
- 任意のTCP/IPパケットを送信する

#### 宛先ポート番号の指定方法(-p)
```
$ hping3 -I eth0(ネットワークインターフェース) -c 1(回数) -p 8080(ポート番号) '**.***.***.***'(IPアドレス)
```

## 参照
- [hping3](https://www.kali.org/tools/hping3/)
