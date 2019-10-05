(* from 浅井健一 著「プログラミングの基礎」 *)

let vegi_list = [("トマト", 300); ("玉ねぎ", 200); ("にんじん", 150); ("ほうれん草", 200)]

(* 目的：item の値段を調べる *)
(* search_price : string -> (string * int) list -> int option *)
exception SoldOut

let rec search_price item lst = match lst with
    [] -> raise SoldOut
  | (vegi, price) :: rest ->
      if item = vegi
      then Some (price)
      else search_price item rest

(* test *)
let test1 = search_price "トマト" vegi_list = Some (300)
