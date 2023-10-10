(* from 浅井健一 著「プログラミングの基礎」 *)

module Tree_t = sig
  type ('a, 'b)

  val empty : ('a, 'b) t

  val insert : ('a, 'b) t -> 'a -> 'b -> ('a, 'b) t

  val search : ('a, 'b) -> 'a -> 'b
end
