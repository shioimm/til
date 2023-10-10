(* from 浅井健一 著「プログラミングの基礎」 *)

#use "price.ml"

let shop_list = [("トマト", 300); ("玉ねぎ", 200);
                  ("にんじん", 150); ("ほうれん草", 200)]

(* 目的：shop_list を買ったときの値段の合計を調べる *)
(* total_price : string list -> (string * int) list -> int *)

let total_price vegi_list shop_list =
  let rec sub vegi_list = match vegi_list with
      [] -> 0
    | first :: rest ->
        search_price first shop_list + sub rest
  in try sub vegi_list with
    SoldOut -> 0

(* test *)
let test1 = total_price ["トマト"; "にんじん"] shop_list = 450
let test2 = total_price ["じゃがいも"; "玉ねぎ"; "にんじん"] shop_list = 350
