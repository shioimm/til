(* 問題18-1 from 浅井健一 著「プログラミングの基礎」 *)

#use "q08_03.ml"

let lst1 = [suzuki; yamada; sato]
let lst2 = [sato; yamada; suzuki]

(* 目的：lst に含まれる最初の A 型の人を返す *)
(* first_A : person_t list -> person_t option *)

let rec first_A lst = match lst with 
    [] -> None
  | first :: rest -> match first with
      {name = n; m = m; kg = kg; month = mon; date = dt; blood_type = bt} ->
        if bt = "A"
        then Some (first)
        else first_A rest

(* test *)
let test1 = first_A [] = None
let test2 = first_A lst1 = Some (yamada)
let test3 = first_A lst2 = Some (yamada)
