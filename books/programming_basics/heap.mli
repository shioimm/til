(* from 浅井健一 著「プログラミングの基礎」 *)

type ('a, 'b) t
type index_t

val create : int -> 'a -> 'b -> ('a, 'b) t
val insert : ('a, 'b) t -> 'a -> 'b -> index_t * ('a, 'b) t
val get : ('a, 'b) t -> index_t -> 'a * 'b
val set : ('a, 'b) t -> index_t -> 'a -> 'b -> ('a, 'b) t
val split_top : ('a, 'b) t -> ('a * 'b) * ('a * 'b) t
