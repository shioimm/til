(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：実数のリスト lst を受け取り各要素の平方根のリストを返す *)
(* map_sqrt : float list -> float list *)

let rec map_sqrt lst =
    [] -> []
  | first :: rest ->
      sqrt first :: map_sqrt rest
