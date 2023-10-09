(* 問題20-2 from 浅井健一 著「プログラミングの基礎」 *)

#use "q20_01.ml"

(* 目的：赤黒木の赤の連続を解消する *)
(* balance : ('a, 'b) rb_tree_t -> ('a, 'b) rb_tree_t *)

let balance rb_tree = match rb_tree with
    Node (Node (Node (a, xa, xb, Red, b), ya, yb, Red, c), za, zb, Black, d)
  | Node (Node (a, xa, xb, Red, Node (b, ya, yb, Red, c)), za, zb, Black, d)
  | Node (a, xa, xb, Black, Node (Node (b, ya, yb, Red, c), za, zb, Red, d))
  | Node (a, xa, xb, Black, Node (b, ya, yb, Red, Node(c, za, zb, Red, d)))
  | Node (Node (Node (a, xa, xb, Red, b), ya, yb, Red, c), za, zb, Black, d) ->
      Node (Node (a, xa, xb, Black, b), ya, yb, Red, Node (c, za, zb, Black, d))
  | _ -> rb_tree

(* test *)
let rb_tree1 =
  Node (Node (Node (Empty, 10, "x", Red, Empty), 13, "y", Red, Empty),
	15, "z", Black, Empty)
let rb_tree2 =
  Node (Node (Empty, 10, "x", Red, Node (Empty, 13, "y", Red, Empty)),
	15, "z", Black, Empty)
let rb_tree3 =
  Node (Empty, 10, "x", Black,
	Node (Node (Empty, 13, "y", Red, Empty), 15, "z", Red, Empty))
let rb_tree4 =
  Node (Empty, 10, "x", Black,
	Node (Empty, 13, "y", Red, Node (Empty, 15, "z", Red, Empty)))
let rb_tree5 =
  Node (Node (Empty, 10, "x", Black, Empty), 13, "y", Red,
	Node (Empty, 15, "z", Black, Empty))
let rb_tree6 = Empty
let test1 = balance rb_tree1 = rb_tree5
let test2 = balance rb_tree2 = rb_tree5
let test3 = balance rb_tree3 = rb_tree5
let test4 = balance rb_tree4 = rb_tree5
let test5 = balance rb_tree6 = rb_tree6
