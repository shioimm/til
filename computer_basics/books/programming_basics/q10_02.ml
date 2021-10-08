(* 問題10-2 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 整数のリストlstと整数nを受け取り、昇順にして返す *)
(* insert : int list -> int list *)

#use "q10_01.ml"

let rec ins_sort lst = match lst with
    [] -> []
  | first :: rest ->
      insert (ins_sort rest) first

(* test *)
let test1 = ins_sort [] = []
let test2 = ins_sort [5; 3; 8; 1; 7; 4] = [1; 3; 4; 5; 7; 8]
