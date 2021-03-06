# 計算量
- 引用元: [Exploring Big-O Notation With Ruby](https://www.honeybadger.io/blog/big-o-notation-ruby/)
- 入力のサイズが変したときアルゴリズムの実行時間がどのように変化するかを記述する

## 計算速度(昇順)
- 参照: なっとく！アルゴリズム / みんなのコンピュータサイエンス
  - n = データ量
- O(1) - 定数
  - ex. ハッシュテーブル
- O(log n) - 対数的
  - ex. 二分探索
- O(n) - 線形的
  - ex. 線形探索
- O(n log n) - 対数線形的
  - ex. クイックソート
- O(n^2) - 二乗的
  - ex. 選択ソート
- O(2^n) - 指数的
- O(n!) - 階乗的
  - ex. 巡回セールスマン問題

## 漸近線
- 極限解析(Limit analysis) -> ある値に近づいた場合の関数に何が起こるかを見る
```
f(x) = x^2 + 4xの場合

xが大きくなるとf(x)は無限大に近づくため、
xが無限大に近づくときのf(x) = x^2 + 4xの極限は無限大である
```
- 漸近解析(Asymptotic analysis) -> f(x)が無限に近づいた場合何が起こるかを見る
```
f(x) = x^2 + 4xの場合

xが非常に大きくなるとx^2項と比較した4x項は相対的に誤差の範囲に納まるようになる
xの値が無限大に近づくときのf(x) = x^2 + 4xはf(x) = x^2とほぼ等価である
```

