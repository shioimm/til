# MRI
#### VALUE型
- ruby/include/ruby/internal/value.h
- オブジェクトの実体である構造体を指すtagged pointer
- unsigned integer、64ビットCPUで8バイト
- R~構造体へのポインタになる (`R~`マクロを利用してキャストされる)
- 下位3ビットのうちいずれかが1の場合はポインタではなく即値として扱われる
  - ポインタ値は8 (ポインタ長) の倍数であり、8の倍数の場合は下位3ビットが0になる
  - 下位3ビットのいずれかが立っている場合は8の倍数ではない = 即値であるとみなされる

| オブジェクトの種類 | ビットの配置      |
| -                  | -                 |
| Fixnum (Integer)   | 下位1ビットが1    |
| Flonum (Float)     | 下位2ビットが01   |
| Symbol             | 下位8ビットが0x0c |
| true               | 0x14              |
| false              | 0                 |
| nil                | 8                 |
| RVALUEへのポインタ | それ以外          |

#### R~構造体 (統一的な名称はない)
- オブジェクトを表す各構造体
- ヘッダ: RBasic構造体 (VALUE構造構造体2つ分)
- ボディ: オブジェクトにより異なる (VALUE構造体3つ分)
  - 足りない場合は追加でメモリを割り当て、確保したメモリへのポインタをボディへ格納
  - 余る場合は余ったままにしておく

#### RBasic構造体
- ruby/include/ruby/internal/core/rbasic.h
- `VALUE flags` -  R~構造体の表現するデータ型と各種フラグ (最初の5ビットでデータ型を示す)
- `const VALUE klass` - オブジェクトのクラス

| データ型     | 用途                                 |
| -            | -                                    |
| `T_OBJECT`   | ユーザー定義オブジェクト             |
| `T_CLASS`    | クラスオブジェクト                   |
| `T_MODULE`   | モジュールオブジェクト               |
| `T_FLOAT`    | Float (浮動小数点数) オブジェクト    |
| `T_STRING`   | 文字列オブジェクト                   |
| `T_REGEXP`   | 正規表現オブジェクト                 |
| `T_ARRAY`    | 配列オブジェクト                     |
| `T_HASH`     | ハッシュオブジェクト                 |
| `T_STRUCT`   | Struct (構造体) オブジェクト         |
| `T_BIGNUM`   | Bignum (大きな整数) オブジェクト     |
| `T_FILE`     | ファイルオブジェクト                 |
| `T_DATA`     | ユーザー定義データ構造オブジェクト   |
| `T_MATCH`    | Matchオブジェクト                    |
| `T_COMPLEX`  | Complex (複素数) オブジェクト        |
| `T_RATIONAL` | Rationa(l 有理数)オブジェクト        |
| `T_IMEMO`    | MRI内部で使うデータ                  |
| `T_NODE`     | MRI内部で使うデータ (ASTノード)      |
| `T_ICLASS`   | MRI内部で使うデータ (mix-in)         |
| `T_ZOMBIE`   | MRI内部で使うデータ (ファイナライザ) |

#### RClass構造体
- ruby/internal/class.h
- `rb_classext_struct`構造体: internal/class.h
  - RClass構造体と1:1で使用する

#### RVALUE構造体
- ruby/gc.c
- Rubyオブジェクトに対するメモリ操作を行う際にラッパーとなる構造体
- `rb_newobj`はRVALUEをfreelistから一つ外して返すための関数

#### ID型
- ruby/unclude/ruby/internal/value.h
- インタプリタ内部で扱う名前を表す一意な番号
  - 各IDは1:1対応する名前を持つ
  - 名前は構文解析の時点でIDに変換される
    - 名前 (C言語の文字列 `char *`) -> ID : `rb_intern(const char *name)`
    - ID -> 名前 (C言語の文字列 `char *`) : `rb_id2name(ID)`
- 32ビットの非負整数値
  - 上位28ビット: ID 番号
  - 中間 3ビット: ID種別
    - ローカル変数 (lvar)
    - インスタンス変数 (@ivar)
    - グローバル変数 ($gvar)
    - セッタ (attr=)
    - 定数 (Const)
    - クラス変数 (@@cvar)
    - その他 (インタプリタ管理用)
  - 下位 1ビット: 静的/動的管理の判別
- Rubyレベルのデータ型として`::rb_cSymbol`が用意されている
- `global_ symbols.str_sym` - 名前 (文字列オブジェクト) とシンボルを対応させるハッシュテーブル
- `global_symbols. ids` - IDと名前 (文字列オブジェクト) を対応させるハッシュテーブル

#### 特殊変数
- ruby/include/ruby/internal/`special_consts.h`

#### `rb_global_tbl`構造体
- variable.c
- グローバル変数を格納するテーブル
- `global_entry`構造体 (グローバル変数のエントリ)
- `global_variable`構造体 (グローバル変数の実体)

#### `st-table`
- ruby/include/ruby/st.h -> ruby/st.c
- ハッシュテーブル
- `NEWOBJ`マクロ: ruby/include/ruby/internal/newobj.h
  - Rubyオブジェクトを生成する際のマクロ
  - R~構造体を割り当てる
- `OBJSETUP`マクロ: ruby/include/ruby/internal/newobj.h
  - Rubyオブジェクトを生成する際のマクロ
  - RBasicのbasic.klassとbasic.flagsを初期化
- VMの命令シーケンスの定義: ruby/insns.def

## 参照
- Rubyのウラガワ ── Rubyインタプリタに学ぶデータ構造とアルゴリズム
  - 【第1回】オブジェクトはどうやって表現するのか？──ポインタと埋め込み表現
  - インタプリタでの名前管理とシンボルGC
