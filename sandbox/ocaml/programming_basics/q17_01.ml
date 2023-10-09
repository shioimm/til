(* 問題17-1 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：生まれた年の年号と現在の年号を受け取ったら年齢を返す *)
(* age : year_t -> year_t -> int *)

#use "to_gregorian.ml"

let age born_in now =
  (to_gregorian now) - (to_gregorian born_in)

(* test *)
let test1 = age (Showa (42)) (Heisei (18)) = 39
let test2 = age (Heisei (11)) (Heisei (18)) = 7
let test3 = age (Meiji (41)) (Heisei (17)) = 97
