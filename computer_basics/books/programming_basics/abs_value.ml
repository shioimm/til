(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 受け取った実数xの絶対値を計算する *)
(* abs_value : float -> float *)

let abs_value x = if x < 0.0 then -. x else x

(* test *)
let test1 = abs_value 1.0 = 1.0
let test2 = abs_value (-2.0) = 2.0
let test3 = abs_value 0.0 = 0.0
