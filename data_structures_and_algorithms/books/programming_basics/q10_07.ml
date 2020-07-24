(* 問題10-7 from 浅井健一 著「プログラミングの基礎」 *)

#use "q08_03.ml"

let lst1 = []
let lst2 = [suzuki]
let lst3 = [yamada]
let lst4 = [suzuki; yamada; sato]

(* 目的 : リスト lst のうち各血液型の人が何人いるかを集計する *)
(* count_bt : person_t list -> int * int * int * int *)

let rec count_bt lst = match lst with
    [] -> (0, 0, 0, 0)
  | { name = n; m = m; kg = kg; month = mn; date = dt; blood_type = bt } :: rest ->
      let (a, b, o, ab) = count_bt rest in
        if bt = "A" then (a + 1, b, o, ab)
        else if bt = "B" then (a + 1, b, o, ab)
        else if bt = "O" then (a, b, o + 1, ab)
        else (a, b, o, ab + 1)

(* test *)
let test1 = count_bt lst1 = (0, 0, 0, 0)
let test2 = count_bt lst2 = (0, 0, 1, 0)
let test3 = count_bt lst3 = (1, 0, 0, 0)
let test4 = count_bt lst4 = (1, 0, 2, 0)
