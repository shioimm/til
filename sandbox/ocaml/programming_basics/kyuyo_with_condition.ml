(* from 浅井健一 著「プログラミングの基礎」 *)

(* 優遇時給(yen) *)
let yugu_jikyu = 980
(* 時給(yen) *)
let jikyu = 950
(* 基本給(yen) *)
let kihonkyu = 100

(* 目的 : 働いた時間xに応じて時給を変更し給与を計算する *)
(* kyuyo : int -> int *)

let kyuyo_with_condition x = kihonkyu + x * (if x < 30 then jikyu else yugu_jikyu)

(* テスト *)
let test1 = kyuyo_with_condition 25 = 23850
let test2 = kyuyo_with_condition 28 = 26700
let test3 = kyuyo_with_condition 31 = 30480
