(* 問題20-1 from 浅井健一 著「プログラミングの基礎」 *)

#use "color.ml"

type ('a, 'b) rb_tree_t =
    Empty
  | Node of ('a, 'b) rb_tree_t * 'a * 'b * color_t * ('a, 'b) rb_tree_t
