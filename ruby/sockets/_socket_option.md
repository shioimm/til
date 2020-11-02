# class Socket::Option
- [class Socket::Option](https://docs.ruby-lang.org/ja/2.7.0/class/Socket=3a=3aOption.html)

## TL;DR
- ソケットオプションクラス

## 継承リスト
```
BasicObject
  |
Kernel
  |
Object
  |
Socket::Option
```

## オプション

| `SO_OOBINLINE` | 受信した帯域外データをインラインに残す |
| `SO_REUSEADDR` | ローカルアドレスの再使用を有効化       |
| `SO_TYPE`      | ソケットのタイプを取得                 |

## オプションの整数表現
### `#int`
- `int(family, level, optname, integer)` -> Socket::Option
  - 整数をデータとして持つ`Socket::Option`オブジェクトを新たに生成する
    - `family` - ソケットファミリー
    - `level` - プロトコル層
    - `optname` - プロトコルモジュールに渡されて解釈されるオプション名
    - `integer` - 整数データ
