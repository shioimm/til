# class BasicSocket
- [class BasicSocket](https://docs.ruby-lang.org/ja/2.7.0/class/BasicSocket.html)

## TL;DR
- 抽象ソケットクラス

## 継承リスト
```
BasicObject
  |
Kernel
  |
Object
  |
File::Constants
  |
Enumerable
  |
IO
  |
BasicSocket
```

## `getsockopt(2)`
### `#getsockopt`
- `getsockopt(level, optname)` -> Socket::Option
  - ソケットに設定されたオプションを取得する
    - `level` - プロトコル層
    - `optname` - プロトコルモジュールに渡されて解釈されるオプション名

## `setsockopt(2)`
### `#setsockopt`
- `setsockopt(level, optname, optval)` -> 0
  - ソケットにオプションを設定する
    - `level` - プロトコル層
    - `optname` - プロトコルモジュールに渡されて解釈されるオプション名
    - `optval` 文字列、整数、真偽値
