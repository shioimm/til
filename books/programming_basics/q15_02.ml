(* 問題15-2 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：m > n > 0 なる自然数 m と n の最大公約数を求める *)
(* gcd : int -> int -> int *)

let rec gcd m n =
  if n = 0
  then m
  else gcd n (m mod n)

(* test *)
let test1 = gcd 7 5 = 1
let test2 = gcd 30 18 = 6
let test3 = gcd 36 24 = 12
