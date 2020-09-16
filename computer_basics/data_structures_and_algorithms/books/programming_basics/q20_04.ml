(* 問題20-4 from 浅井健一 著「プログラミングの基礎」 *)

#use "q20_01.ml"

(* 目的：赤黒木とキーを受け取ったら、そのキーに対応する値を返す *)
(* search : ('a, 'b) rb_tree_t -> 'a -> 'b *)

let rec search rb_tree k = match rb_tree with
    Empty -> raise Not_found
  | Node (left, key, value, color, right) ->
      if k = key
      then value
      else if k < key
      then search left k
      else search right k

(* test *)
let rb_tree =
  Node (Node (Empty, 10, "x", Black, Empty), 13, "y", Red,
	Node (Empty, 15, "z", Black, Empty))
let test1 = search rb_tree 10 = "x"
let test2 = search rb_tree 13 = "y"
let test3 = search rb_tree 15 = "z"
