# `rb_scan_args`

```
* scan-arg-spec                  : param-arg-spec [keyword-arg-spec] [block-arg-spec]

* param-arg-spec                 : pre-arg-spec [post-arg-spec]
                                 : post-arg-spec
                                 : pre-opt-post-arg-spec

* pre-arg-spec                   : num-of-leading-mandatory-args [num-of-optional-args]

* post-arg-spec                  : sym-for-variable-length-args [num-of-trailing-mandatory-args]

* pre-opt-post-arg-spec          : num-of-leading-mandatory-args num-of-optional-args num-of-trailing-mandatory-args

* keyword-arg-spec               : sym-for-keyword-arg

* block-arg-spec                 : sym-for-block-arg

* num-of-leading-mandatory-args  : 数値 ; 先頭の必須引数の数

* num-of-optional-args           : 数値 ; 先頭の必須引数の後に受け取るオプション引数

* sym-for-variable-length-args   : "*"  ; 可変長の引数をRubyの配列として受け取る

* num-of-trailing-mandatory-args : 数値 ; 可変長引数の後に受け取る末尾の必須引数の数

* sym-for-keyword-arg            : ":"  ; キーワード引数をハッシュとして受け取る (なしの場合nil)

* sym-for-block-arg              : "&"  ; ブロックを引数として受け取る
```

#### 例
- `"22:"` = 先頭の必須引数二個 + オプション引数二個 + 任意個のキーワード引数 (`TCPSocket.new`)
- `"01"`  = オプション引数1個 (`BasicSocket#shutdown`)
- `"0*:"` = 可変長引数 + 任意個のキーワード引数 (`Struct.new`)
