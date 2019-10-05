(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 現在の気温tが15度以上25度以下かどうかを真偽判定する *)
(* kaiteki : int -> bool *)

let kaiteki t =
  15 <= t && t <= 25

(* test *)
let test1 = kaiteki 7 = false
let test2 = kaiteki 15 = true
let test3 = kaiteki 20 = true
let test4 = kaiteki 25 = true
let test5 = kaiteki 28 = false

(* 目的 : 現在の気温tから快適度を表す文字列を計算する *)
(* kion : int -> string *)

let kion t =
  if kaiteki t then "快適"
               else "普通"

(* test *)
let test6 = kion 7 = "普通"
let test7 = kion 15 = "快適"
let test8 = kion 20 = "快適"
let test9= kion 25 = "快適"
let test10 = kion 28 = "普通"
