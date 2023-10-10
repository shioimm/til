(* 問題4-7 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 鶴と亀の数に応じて足の数を計算する *)
(* count_num_of_legs : int -> int *)

let count_num_of_legs crane turtle = crane * 2 + turtle * 4

(* test *)

let test1 = count_num_of_legs 1 1 = 6
let test2 = count_num_of_legs 5 10 = 50
let test3 = count_num_of_legs 12 6 = 48
