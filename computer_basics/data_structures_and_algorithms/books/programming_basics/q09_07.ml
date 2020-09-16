(* 問題9-7 from 浅井健一 著「プログラミングの基礎」 *)

#use "q08_03.ml" ;;

(* 目的 : リストを受け取り、血液型がAの人の人数を返す *)
(* count_a : person_t -> int *)

let count_a lst = match lst with
  [] -> 0
  | { name = n; m = m; kg = kg; month = mon; date = date;
   blood_type = bt } :: rest
   -> if bt = "A"
      then 1 + count_a rest
      else count_a rest

let list1 = []
let list2 = [yamada; suzuki]
let list3 = [suzuki]

(* test *)
let test1 = count_a list1 = 0
let test2 = count_a list2 = 1
let test3 = count_a list3 = 0
