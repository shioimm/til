(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：与えられたリストを逆順にして返す *)
(* reverse : 'a list -> 'a list *)

let rec reverse lst =
  let rec rev lst result = match lst with
      [] -> result
    | first :: rest ->
        rev rest (first :: result)
  in rev lst []

(* test *)
let test1 = reverse [] = []
let test2 = reverse [1] = [1]
let test3 = reverse [1; 2; 3; 4; 5] = [5; 4; 3; 2; 1]
