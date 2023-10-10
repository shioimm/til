(* 問題9-5 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 受け取ったリストから偶数のみをリストにして返す *)
(* even : int list -> list *)
let rec even lst = match lst with
  [] -> []
  | first :: rest -> if first mod 2 = 0
                     then first :: even rest
                     else even rest

(* test *)
let test1 = even [1; 2] = [2]
let test2 = even [0; 1; 2; 3; 4] = [0; 2; 4]
let test3 = even [1; 3] = []
let test4 = even [] = []
