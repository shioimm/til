(* 問題17-7 from 浅井健一 著「プログラミングの基礎」 *)

#use "sum_tree.ml"

(* 目的：tree に含まれる節と葉の数の合計を返す *)
(* tree_length : tree_t -> int *)

let rec tree_length tree = match tree with
    Empty -> 0
  | Leaf (n) -> 1
  | Node (t1, n, t2) -> tree_length t1 + 1 + tree_length t2

(* test *)
let test1 = tree_length tree1 = 0
let test2 = tree_length tree2 = 1
let test3 = tree_length tree3 = 2
let test4 = tree_length tree4 = 4
