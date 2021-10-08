(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 受け取ったリストに0が含まれているかを調べboolを返す *)
(* contain_zero : int list -> bool *)

let rec contain_zero lst = match lst with
  [] -> false
  | first :: rest -> if first = 0 then true
                                  else contain_zero rest

(* test *)
let test1 = contain_zero [] = false
let test2 = contain_zero [0; 1] = true
let test3 = contain_zero [1; 2] = false
let test4 = contain_zero [1; 2; 3; 4; 0; 5;] = true
let test5 = contain_zero [1; 2; 3; 4; 5;] = false
