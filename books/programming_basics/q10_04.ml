(* 問題10-4 from 浅井健一 著「プログラミングの基礎」 *)

#use "ex08_03.ml"

let lst1 = []
let lst2 = [suzuki]
let lst3 = [suzuki; yamada]
let lst4 = [yamada; suzuki]

let person_insert lst person0 = match lst with
    [] -> []
  | ({ name = n1; m = m1; kg = kg1; mon = mn1; date = d1; blood_type = bt1 } as person1) :: rest ->
      match person0 with
        { name = n0; m = m0; kg = kg0; mon = mn0; date = d0; blood_type = bt0 } ->
          if n0 > n1
          then person1 :: person_insert rest person0
          else person0 :: lst

(* test *)
let test1 = person_insert [] suzuki = [suzuki]
let test2 = person_insert [yamada] suzuki = [suzuki; yamada]
let test3 = person_insert [suzuki] yamada = [suzuki; yamada]
let person_ins_sort lst = match lst with
    [] -> []
  | first :: rest ->
      person_insert (person_ins_sort rest) first

(* test *)
let test5 = person_ins_sort lst1 = []
let test6 = person_ins_sort lst2 = [suzuki]
let test7 = person_ins_sort lst3 = [suzuki; yamada]
let test8 = person_ins_sort lst4 = [suzuki; yamada]
