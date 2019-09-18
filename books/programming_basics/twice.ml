(* from 浅井健一 著「プログラミングの基礎」 *)

let twice f =
  let g x = f (f  x) in g
