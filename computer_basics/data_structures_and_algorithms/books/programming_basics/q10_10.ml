(* 問題10-10 from 浅井健一 著「プログラミングの基礎」 *)

#use "q09_09.ml"

(* 目的：ローマ字の駅名を漢字に直す *)
(* roman_to_name : string -> information_t list -> string *)
let rec roman_to_name rm0 lst = match lst with
    [] -> ""
  | { name=n; kana=k; roman=rm1; route=rt } :: rest ->
      if rm0 = rm1
      then n
      else roman_to_name rm0 rest

(* test *)
let test1 = roman_to_name "myogadani" global_information_list = "茗荷谷"
let test2 = roman_to_name "shibuya" global_information_list = "渋谷"
let test3 = roman_to_name "otemachi" global_information_list = "大手町"
