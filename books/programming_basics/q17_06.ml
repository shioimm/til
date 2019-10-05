(* 問題17-6 from 浅井健一 著「プログラミングの基礎」 *)

#use "sum_tree.ml"

(* 目的：tree の各要素に f を適用した木を返す *)
(* tree_map : (int -> int) -> tree_t -> tree_t *)

let rec tree_map f tree = match tree with
    Empty -> Empty
  | Leaf (n) -> Leaf (f n)
  | Node (t1, n, t2) -> Node (tree_map f t1, f n, tree_map f t2)

(* test *)
let test1 = tree_map (fun x -> x) tree1 = Empty
let test2 = tree_map (fun x -> x + 1) tree2 = Leaf (4)
let test3 = tree_map (fun x -> x * 3) tree3 = Node (Empty, 12, Leaf (9))
let test4 = tree_map (fun x -> x * 2) tree4
	    = Node (Leaf (6), 10, Node (Empty, 8, Leaf (6)))
