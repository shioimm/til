(* 問題13-4 from 浅井健一 著「プログラミングの基礎」 *)

let compose times2 add3 =
  let inner_compose x = times2 (add3 x) in inner_compose

let times2 x = 2 * x

let add3 x = 3 + x

(* test *)
let test = (compose times2 add3) 4 = 14
