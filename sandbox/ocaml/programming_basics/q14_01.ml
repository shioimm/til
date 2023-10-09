(* 問題14-1 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：受け取った整数が偶数かどうかを判定する *)
(* is_even : int -> bool *)

let is_even n =
  n mod 2 = 0

(* 目的：受け取ったリストの中から偶数のみを抜き出したリストを返す *)
(* even : int list -> int *)
let even lst = List.filter is_even lst

(* test *)
let test1 = even [] = []
let test2 = even [3] = []
let test3 = even [2] = [2]
let test4 = even [2; 1; 6; 4; 7] = [2; 6; 4]
let test5 = even [1; 2; 6; 4; 7] = [2; 6; 4]
