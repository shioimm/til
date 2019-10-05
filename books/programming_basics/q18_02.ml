(* 問題18-2 from 浅井健一 著「プログラミングの基礎」 *)

#use "price.ml"

let shop_list = [("トマト", 300); ("玉ねぎ", 200); ("にんじん", 150); ("ほうれん草", 200)]

(* 目的：八百屋リストには入っていない野菜の数を返す *)
(* sold_outs : string list -> (string * int) list -> int *)

let rec sold_outs vegi_list shop_list = match vegi_list with
    [] -> 0
  | first :: rest ->
      match search_price first shop_list with
        None -> 1 + sold_outs rest shop_list
      | Some (p) -> sold_outs rest shop_list

(* test *)
let test1 = sold_outs ["玉ねぎ"; "にんじん"] shop_list = 0
let test2 = sold_outs ["玉ねぎ"; "じゃがいも"; "にんじん"] shop_list = 1
let test3 = sold_outs ["しいたけ"; "なす"; "にんじん"] shop_list = 2
