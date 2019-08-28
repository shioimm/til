(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 二つの整数の組pairを受け取り、その要素の和を返す *)
(* add : int * int -> int *)

let add pair = match pair with
  (a, b) -> a + b

(* test *)
let test1 = add (0, 0) = 0
let test2 = add (3, 5) = 8
let test3 = add (3, -5) = -2
