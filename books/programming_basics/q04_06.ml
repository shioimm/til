(* 問題4-6 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 鶴の数に応じて足の数を計算する *)
(* count_num_of_crane_legs : int -> int *)

let count_num_of_crane_legs x = x * 2

(* test *)

let test1 = count_num_of_crane_legs 1 = 2
let test2 = count_num_of_crane_legs 5 = 10
let test3 = count_num_of_crane_legs 125 = 250

(* 目的 : 亀の数に応じて足の数を計算する *)
(* count_num_of_turtle_legs : int -> int *)

let count_num_of_turtle_legs x = x * 4

(* test *)

let test1 = count_num_of_turtle_legs 1 = 4
let test2 = count_num_of_turtle_legs 5 = 20
let test3 = count_num_of_turtle_legs 125 = 500
