(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：lst 中の整数をすべて掛け合わせる *)
(* times : int list -> int *)

exception Zero

let rec times lst =
  let rec sub lst = match lst with
      [] -> 1
    | first :: rest ->
        if first = 0
        then raise Zero
        else first * times rest
  in try sub lst
  with Zero -> 0

(* test *)
let test1 = times [3; 1; 4] = 12
let test2 = times [0] = 0
let test3 = times [3; 1; 0; 4] = 0
let test4 = times [3; 2; 1; 0] = 0
