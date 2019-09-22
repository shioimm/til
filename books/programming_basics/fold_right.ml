(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：init から始めて lst の要素を右から順に f を施しこむ *)
(* fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b *)

let rec fold_right f lst init = match lst with
    [] -> init
  | first :: rest ->
      f first (fold_right f rest init)

(* 目的：受け取ったリスト lst の各要素の和を求める *)
(* sum : int list -> int *)

let sum lst =
    (* 目的：first と rest_result を加える *)
    (* add_int : int -> int -> int *)
    let add_int first rest_result = first + rest_result
    in fold_right add_int lst 0


(* test *)
let test1 = sum [] = 0
let test2 = sum [1; 2; 3] = 6
let test3 = sum [1; 3; 7; 4; 2; 8] = 25

(* 目的：受け取ったリスト lst の長さを求める *)
(* length : 'a list -> int *)

let length lst = fold_right (fun first rest_result -> 1 + rest_result) lst 0

(* test *)
let test4 = length [] = 0
let test5 = length [1; 2; 3] = 3
let test6 = length [1; 3; 7; 4; 2; 8] = 6

(* 目的：lst1 と lst2 を受け取りそれらを結合したリストを返す *)
(* append : 'a list -> 'a list -> 'a list *)

let rec append lst1 lst2 = fold_right (fun first rest_result -> first :: rest_result) lst1 lst2

(* test *)
let test7 = append [] [] = []
let test8 = append [1; 2; 3] [4; 5; 6] = [1; 2; 3; 4; 5; 6]
let test9 = append [1; 3; 7; 4; 2; 8] [9; 6; 5] = [1; 3; 7; 4; 2; 8; 9; 6; 5]
