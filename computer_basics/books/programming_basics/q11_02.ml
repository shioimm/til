(* 問題11-02 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：問題に与えられた漸化式の一般項を求める *)
(* a : int -> int *)

let rec a n =
  if n = 0
  then 3
  else 2 * a (n - 1) - 1

(* test *)
let test1 = a 0 = 3
let test2 = a 1 = 5
let test3 = a 2 = 9
let test4 = a 3 = 17
let test5 = a 4 = 33
