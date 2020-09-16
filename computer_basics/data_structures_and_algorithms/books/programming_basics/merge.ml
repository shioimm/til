(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：昇順に並んでいるリスト lst1 と lst2 をマージする *)
(* merge : int list -> int list -> int list *)

let rec merge lst1 lst2 = match (lst1, lst2) with
    ([], []) -> []
  | ([], first2 :: rest2) -> lst1
  | (first1 :: rest1, []) -> lst2
  | (first1 :: rest1, first2 :: rest2) ->
      if first1 > first2
      then first1 :: merge rest1 lst2
      else first2 :: merge lst1 rest2


(* test *)
let test1 = merge [] [] = []
let test2 = merge [] [1; 2] = [1; 2]
let test3 = merge [1; 2] [] = [1; 2]
let test4 = merge [1; 3] [2; 4] = [1; 2; 3; 4]
let test5 = merge [2; 4] [1; 3] = [1; 2; 3; 4]
let test6 = merge [1; 4] [1; 3] = [1; 1; 3; 4]
