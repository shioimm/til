(* 問題14-15 from 浅井健一 著「プログラミングの基礎 *)

(* 目的：n から 1 までのリストを作る *)
(* enumerate : int -> int list *)

let rec enumerate n =
  if n = 0
  then []
  else n :: enumerate (n - 1)

(* 目的：1 から受け取った自然数 n までの合計を返す *)
(* one_to_n : int -> int *)

let one_to_n n =
  List.fold_right (+) (enumerate n) 0

(* test *)
let test1 = one_to_n 0 = 0
let test2 = one_to_n 1 = 1
let test3 = one_to_n 2 = 3
let test4 = one_to_n 10 = 55
