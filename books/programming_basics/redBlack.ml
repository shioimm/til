(* from 浅井健一 著「プログラミングの基礎」 *)

type color_t = Red | Black

type ('a, 'b) t =
    Empty
  | Node of ('a, 'b) t * 'a * 'b * color_t * ('a, 'b) t

let empty = Empty

let balance rb_tree = match rb_tree with
    Node (Node (Node (a, xa, xb, Red, b), ya, yb, Red, c), za, zb, Black, d)
  | Node (Node (a, xa, xb, Red, Node (b, ya, yb, Red, c)), za, zb, Black, d)
  | Node (a, xa, xb, Black, Node (Node (b, ya, yb, Red, c), za, zb, Red, d))
  | Node (a, xa, xb, Black, Node (b, ya, yb, Red, Node (c, za, zb, Red, d))) ->
      Node (Node (a, xa, xb, Black, b), ya, yb, Red, Node (c, za, zb, Black, d))
  | _ -> rb_tree

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

let rec search rb_tree k = match rb_tree with
    Empty -> raise Not_found
  | Node (left, key, value, color, right) ->
      if k = key then value
      else if k < key then search left k
      else search right k

let rec traverse f init tree = match tree with
    Empty -> init
  | Node (left, key, value, _, right) ->
      let result1 = f init key value in
      let result2 = traverse f result1 left in
      let result3 = traverse f result2 right in result3

let rec length tree = match tree with
    Empty -> 0
  | Node (left, key, value, _, right) ->
      length left + 1 + length right
