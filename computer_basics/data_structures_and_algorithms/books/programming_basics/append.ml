(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：lst1 と lst2 を受け取りそれらを結合したリストを返す *)
(* append : 'a list -> 'a list -> 'a list *)
let rec append lst1 lst2 = match lst1 with
    [] -> lst2
  | first :: rest ->
      first :: append rest lst2

(* test *)
let test1 = append [] [] = []
let test2 = append [] [1; 2] = [1; 2]
let test3 = append [1; 2] [] = [1; 2]
let test4 = append [1; 2] [3; 4] = [1; 2; 3; 4]
let test5 = append ["a"; "b"; "c"; "d"; "e"] ["f"; "g"] = ["a"; "b"; "c"; "d"; "e"; "f"; "g"]
