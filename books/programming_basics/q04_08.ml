(* 問題4-8 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 鶴と亀の合計数と足の合計に応じて鶴の数を計算する *)
(* count_num_of_legs : int -> int *)

let count_num_of_crane num_of_animals num_of_legs = (num_of_animals * 4 - num_of_legs) / 2

(* test *)

let test1 = count_num_of_crane 2 6 = 1
let test2 = count_num_of_crane 5 16 = 2
let test3 = count_num_of_crane 20 66 = 7
