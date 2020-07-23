(* from 浅井健一 著「プログラミングの基礎」 *)

type ('a, 'b) t

val empty : ('a, 'b) t

val insert : ('a, 'b) t -> 'a -> 'b -> ('a, 'b) t

val search : ('a, 'b) t -> 'a -> 'b

val traverse : ('a -> 'b -> 'c -> 'a) -> 'a -> ('b, 'c) t -> 'a

val length : ('a, 'b) t -> int
