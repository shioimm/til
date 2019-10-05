(* 問題17-8 from 浅井健一 著「プログラミングの基礎」 *)

#use "sum_tree.ml"

(* 目的：tree に含まれる節と葉の数の合計を返す *)
(* tree_depth : tree_t -> int *)

let rec tree_depth tree = match tree with
    Empty -> 0
  | Leaf (n) -> 0
  | Node (t1, n, t2) -> 1 + max (tree_depth t1)(tree_depth t2)

(* test *)
let test1 = tree_depth tree1 = 0
let test2 = tree_depth tree2 = 0
let test3 = tree_depth tree3 = 1
let test4 = tree_depth tree4 = 2
