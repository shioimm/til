# ASN.1 (Abstract Syntax Notation 1)
- 構造化データを表すための抽象構文の記法
- 主に通信プロトコルで扱われるデータの送受信単位（PDU：Protocol Data Unit) のデータ構造と、
  PDUの転送時のバイナリ形式の定義に使用される
- 名前と型によって定義されるオブジェクトを列挙してデータ構造を定義し、
  定義された構文を用いて具体的な値を持つインスタンスを記述す

```
FooProtocol DEFINITIONS ::= BEGIN

    FooRequest ::= SEQUENCE {
        trackingNumber INTEGER,
        request        VisibleString
    }

    FooResponse ::= SEQUENCE {
        requestNumber INTEGER,
        response      BOOLEAN
    }

END
```

## 参照
- [ASN.1](https://e-words.jp/w/ASN.1.html)
- [Abstract Syntax Notation One](https://ja.wikipedia.org/wiki/Abstract_Syntax_Notation_One)
