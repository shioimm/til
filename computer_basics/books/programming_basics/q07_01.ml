(* 問題7-1 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 3教科の点数を与えると、その合計点と平均点の組を返す *)
(* sum_and_avg : int -> (float, float) *)

let sum_and_avg x y z = (x +. y +. z, (x +. y +. z) /. 3.0)

(* test *)
let test1 = sum_and_avg 60.0 50.0 70.0 = (180.0, 60.0)
let test2 = sum_and_avg 90.0 50.0 40.0 = (180.0, 60.0)
let test3 = sum_and_avg 95.0 95.0 80.0 = (270.0, 90.0)
