(* 問題9-4 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 受け取ったリストの長さを返す *)
(* length : int list -> int *)
let rec length lst = match lst with
  [] -> 0
  | first :: rest -> 1 + length rest

(* test *)
let test1 = length [1; 2] = 2
let test2 = length [0; 5; 10;] = 3
let test3 = length [] = 0
