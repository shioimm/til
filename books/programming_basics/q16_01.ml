(* 問題16-1 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：先頭からリスト中の各整数までの合計を計算する *)
(* sum_list : int list -> int list *)

let rec sum_list lst =
  let rec sub lst total = match lst with
      [] -> []
    | first :: rest ->
        first + total :: sub rest (first + total)
  in sub lst 0

(* test *)
let test1 = sum_list [] = []
let test2 = sum_list [1; 2; 3] = [1; 3; 6]
let test3 = sum_list [3; 2; 1; 4] = [3; 5; 6; 10]
