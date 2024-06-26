# 乱数
#### 乱数に求められる性質
- 無作為性 - 統計的な偏りがなく、でたらめな数列になっている
- 予測不可能性 - 無作為性を兼ね、過去の数列から次の数を予測できない
- 再現不可能性 - 無作為性・予測不可能性を兼ね、同じ数列を再現できない

| -            | 無作為性 | 予測不可能性 | 再現不可能性 | 暗号技術への利用 | ソフトウェアのみでの生成 |
| -            | -        | -            | -            | -                | -                        |
| 疑似乱数(弱) | ○        | -            | -            | 不可             | 可能                     |
| 疑似乱数(強) | ○        | ○            | -            | 可能             | 可能                     |
| 乱数         | ○        | ○            | ○            | 可能             | 不可                     |

- 擬似乱数生成器 - 乱数を生成するソフトウェア
- 乱数生成器 - 熱や音の変化なども加えて再現不可能な乱数を生成するハードウェア

#### 用途
- 鍵の生成(共通鍵暗号、MAC)
- 鍵ペアの生成(公開鍵暗号、デジタル署名)
- 初期化ベクトルの生成(ブロック暗号のCBC、CFB、OFBモード)
- nonceの生成(再送攻撃防止、ブロック暗号のCTRモード)
- ソルトの生成(パスワードを元にした暗号(PBE)など)

## 擬似乱数
- 疑似乱数 - 種 (シード: 初期値) からあるアルゴリズムによって出力された一見真の乱数に見える乱数列
- 疑似乱数生成器 - 疑似乱数を生成するアルゴリズム・装置

#### 疑似乱数生成器 (PRF: pseudorandom function)
- 内部状態を持ち、外部から与えられた種を元に疑似乱数列を生成する装置
  - 内部状態 - 擬似乱数生成器が管理するメモリの値
  - 種 - 内部状態を初期化するためのランダムなビット列
- 内部状態から疑似乱数を計算する方法と内部状態を変化させる方法をアルゴリズムとして実装する

#### 擬似ランダム関数 (PRF: pseudorandom function)
- 種を与えた時、任意の値に対して疑似乱数を生成する関数

## 参照
- 暗号技術入門 第3版
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
