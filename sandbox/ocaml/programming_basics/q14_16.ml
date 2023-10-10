(* 問題14-16 from 浅井健一 著「プログラミングの基礎 *)

(* 目的：n から 1 までのリストを作る *)
(* enumerate : int -> int list *)
let rec enumerate n =
  if n = 0
  then []
  else n :: enumerate (n - 1)

(* 目的：自然数 n の階乗を求める *)
(* fac : int -> int *)

let fac n =
  List.fold_right ( * ) (enumerate n) 1

(* test *)
let test1 = fac 0 = 1
let test2 = fac 1 = 1
let test3 = fac 2 = 2
let test4 = fac 3 = 6
let test5 = fac 4 = 24
let test6 = fac 10 = 3628800
