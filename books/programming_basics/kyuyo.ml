(* from 浅井健一 著「プログラミングの基礎」 *)

(* 時給(yen) *)
let jikyu = 950
(* 基本給(yen) *)
let kihonkyu = 100

(* 目的 : 働いた時間xに応じた給与を計算する *)
(* kyuyo : int -> int *)

let kyuyo x = kihonkyu + x * jikyu

(* test *)
let test1 = kyuyo 25 = 23850
let test2 = kyuyo 28 = 26700
let test3 = kyuyo 31 = 29550
