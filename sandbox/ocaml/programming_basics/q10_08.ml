(* 問題10-8 from 浅井健一 著「プログラミングの基礎」 *)

#use "q10_07.ml"

let lst1 = [suzuki]
let lst2 = [yamada]
let lst3 = [suzuki; yamada; sato]

(* 目的 : リスト lst のうち最多の血液型を返す *)
(* count_bt : person_t list -> string *)

let rec max_bt lst =
  let (a, b, o, ab) = count_bt lst in
  let max = max (max a b) (max o ab) in
    if max = a then "A"
    else if max = b then "B"
    else if max = o then "O"
    else "AB"

(* test *)
let test1 = max_bt lst2 = "A"
let test2 = max_bt lst3 = "O"
let test3 = max_bt lst4 = "O"
