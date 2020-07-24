(* 問題5-2 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 時間を受け取り、午前か午後かを返す *)
(* time : int -> string *)

let time x = if x <= 12 then "AM" else "PM"

(* test *)
let test1 = time 0 = "AM"
let test1 = time 10 = "AM"
let test1 = time 12 = "AM"
let test1 = time 20 = "PM"
let test1 = time 23 = "PM"
