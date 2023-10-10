(* 問題20-3 from 浅井健一 著「プログラミングの基礎」 *)

#use "q20_02.ml"

(* 目的：赤黒木とキーと値を受け取ったら、それを挿入した赤黒木を返す *)
(* insert : ('a, 'b) rb_tree_t -> 'a -> 'b -> ('a, 'b) rb_tree_t *)

let insert rb_tree k v =
  let rec ins rb_tree = match rb_tree with
      Empty -> Node (Empty, k, v, Red, Empty)
    | Node (left, key, value, color, right) ->
      if k = key
      then Node (left, k, v, color, right)
      else if k < key
      then balance (Node (ins left, key, value, color, right))
      else balance (Node (left, key, value, color, ins right))
  in match ins rb_tree with
      Empty -> assert false
    | Node (left, key, value, color, right) ->
        Node (left, key, value, Black, right)

(* test *)
let rb_tree0 = Empty
let rb_tree1 = insert rb_tree0 10 "x"
let rb_tree2 = insert rb_tree1 13 "y"
let rb_tree3 = insert rb_tree2 15 "z"

let test1 = rb_tree1 = Node (Empty, 10, "x", Black, Empty)
let test2 = rb_tree2 = Node (Empty, 10, "x", Black, Node (Empty, 13, "y", Red, Empty))
let test3 = rb_tree3 = Node (Node (Empty, 10, "x", Black, Empty), 13, "y", Black, Node (Empty, 15, "z", Black, Empty))
