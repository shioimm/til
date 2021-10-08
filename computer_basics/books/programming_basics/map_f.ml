(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：関数 f とリスト lst を受け取り f を施したリストを返す *)
(* map_f : ('a -> 'b) -> 'a list -> 'b list *)

let rec map_f lst func = match lst with
    [] -> []
  | first :: rest ->
      func first :: map_f lst func
