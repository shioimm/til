(* from 浅井健一 著「プログラミングの基礎」 *)

#use "notice.ml"

(* 目的：学生のリスト lst を受け取り成績を入れたリストを返す *)
(* map_eval : gakusei_t list -> gakusei_t list *)

let rec map_eval lst = match lst with
    [] -> []
  | first :: rest ->
      evaluation first :: map_eval rest
