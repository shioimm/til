(* 問題13-3 from 浅井健一 著「プログラミングの基礎」 *)

(* f1 : 'a -> 'a *)
let f1 x = x

(* f2 : 'a -> 'b -> 'a *)
let f2 x y = x

(* f3 : 'a -> 'b -> 'b *)
let f3 x y = y

(* f4 : 'a -> ('a -> 'b) -> 'b *)
let f4 x f = f x

(* f5 : ('a -> 'b) -> ('b -> 'c) -> 'a -> 'c *)
let f5 f g x = g (f x)
